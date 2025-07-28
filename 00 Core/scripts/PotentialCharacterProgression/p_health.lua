-- Health functions
local async = require('openmw.async')
local core = require('openmw.core')
local I = require('openmw.interfaces')
local self = require('openmw.self')
local storage = require('openmw.storage')
local types = require('openmw.types')

local info = require('scripts.PotentialCharacterProgression.info')

local IName = info.interfaceName

-- Game settings
local gameSettings = {
    levelHealthMult = core.getGMST('fLevelUpHealthEndMult')
}

-- Mod settings
local modSettings = {
    health = storage.playerSection('SettingsPlayer' .. info.name .. 'Health')
}

-- Health settings configuration with dependent settings already accounted for
local healthConfig = {}

local function updateHealthConfig()
    healthConfig.isRetroactive = modSettings.health:get('RetroactiveHealth')
    healthConfig.isBaseRetroactive = healthConfig.isRetroactive and modSettings.health:get('RetroactiveStartHealth')
    healthConfig.isGradual = healthConfig.isRetroactive and modSettings.health:get('GradualRetroactiveHealth')
    healthConfig.gradualIncrement = modSettings.health:get('GradualRetroactiveHealthIncrement')
    healthConfig.isCustom = modSettings.health:get('CustomHealth')
    healthConfig.customWeights = modSettings.health:get('CustomHealthCoefficients')
    healthConfig.levelHealthMult = (healthConfig.isCustom and modSettings.health:get('CustomGainMultiplier')) or gameSettings.levelHealthMult
end

updateHealthConfig()

-- Player data/functions

local Player = types.Player

local playerStats = Player.stats
local playerHealth = playerStats.dynamic.health
local playerAttributes = playerStats.attributes

local function getPlayerRecords()
    local playerRecord = Player.record(self)
    return {
        class = Player.classes.record(playerRecord.class),
        race = Player.races.record(playerRecord.race),
        sex = (playerRecord.isMale and 'male') or 'female'
    }
end

-- Calculate starting attribute values, not factoring in birthsigns
local function getStartingAttributes()
    if not startAttributes then
        local playerRecords = getPlayerRecords()
        startAttributes = {}
        for i, attributeRecord in ipairs(core.stats.Attribute.records) do
            local attributeId = attributeRecord.id
            startAttributes[attributeId] = playerRecords.race.attributes[attributeId][playerRecords.sex]
        end
        for _, attributeId in pairs(playerRecords.class.attributes) do
            startAttributes[attributeId] = startAttributes[attributeId] + 10
        end
    end
    return startAttributes
end

-- Get current base attribute values
local function getBaseAttributes()
    local baseAttributes = {}
    for i, attributeRecord in ipairs(core.stats.Attribute.records) do
        local attributeId = attributeRecord.id
        baseAttributes[attributeId] = playerAttributes[attributeId](self).base
    end
    return baseAttributes
end

-- Health functions

-- Increase max health, apply increase to current health as well
local function increaseHealth(healthIncrease)
    I[IName].inc('totalHealthGained', healthIncrease)
    -- This can kill the player if they've messed around with character creation commands, which is pretty funny
    playerHealth(self).base = playerHealth(self).base + healthIncrease
    playerHealth(self).current = math.min(math.max(playerHealth(self).current + healthIncrease, 1), playerHealth(self).base)
end

-- Calculate weighted average with given attribute weights
local function calculateWeightedAverage(attributes, weights)
    local average = 0
    local weightsSum = 0
    for attributeId, attribute in pairs(attributes) do
        local weight = weights[attributeId] or 0
        average = average + attribute * weight
        weightsSum = weightsSum + math.max(weight, 0)
    end
    if weightsSum == 0 then
        return 0
    else
        return average / weightsSum
    end
end

-- Calculate base health from settings or under vanilla conditions
local function calculateBaseHealth(vanilla)
    local attributes = getBaseAttributes()
    local weights = {strength = 1, endurance = 1}
    if vanilla then
        attributes = getStartingAttributes()
    elseif healthConfig.isCustom then
        weights = healthConfig.customWeights
    end
    return calculateWeightedAverage(attributes, weights)
end

-- Given attribute values, calculate health gained from a specified number of level-ups
local function calculateLevelHealth(attributes, gainLevels)
    if healthConfig.isGradual then
        -- Calculate sums of attribute values for each level-up assuming fastest possible growth            ___
        -- Use a triangular number (n * (n + 1) / 2) to calculate the growing attribute totals            /|   |
        -- Not guaranteed that growth matches actual attribute value under incremental conditions        |-|   |
        local summedAttributes = {}
        for attributeId, currentValue in pairs(attributes) do
            local attributeUps = I[IName].attributeGet(attributeId, 'ups')
            -- Number of levels needed/available to increment the starting value up to the current value
            local growingLevels = math.min(math.ceil(attributeUps / healthConfig.gradualIncrement), gainLevels)
            local growingAttributeUps = growingLevels * healthConfig.gradualIncrement
            -- Difference between the actual attribute value and the theoretical incremented value
            local difference = growingAttributeUps - math.min(growingAttributeUps, attributeUps)
            -- Contribution from starting attribute value over growing interval
            local base = growingLevels * (currentValue - attributeUps)
            -- Contribution from attribute increases over growing interval
            local triangle = healthConfig.gradualIncrement * growingLevels * (growingLevels + 1) / 2 - difference
            -- Contribution from actual attribute value after growing interval
            local plateau = (gainLevels - growingLevels) * currentValue
            summedAttributes[attributeId] = base + triangle + plateau
        end   
        attributes = summedAttributes
        gainLevels = 1
    end
    local weights = {endurance = 1}
    if healthConfig.isCustom then
        weights = healthConfig.customWeights
    end
    return calculateWeightedAverage(attributes, weights) * healthConfig.levelHealthMult * gainLevels
end

-- Update the player's maximum health, accounting for relevant settings
-- Only uses attributes and gainLevels when not retroactive
-- When gainLevels is falsy, calculate retroactively regardless of settings
local function updateHealth(attributes, gainLevels)
    -- Health from character generation
    local baseHealth = 0
    -- Health already accounted for in prior health calculations
    local overlap = 0
    
    if healthConfig.isRetroactive or not gainLevels then
        baseHealth = calculateBaseHealth()
        overlap = calculateBaseHealth(true) + I[IName].get('totalHealthGained')
        
        attributes = getBaseAttributes()
        gainLevels = I[IName].get('levelUps')
    end
    
    -- Health gained from level-ups
    local levelHealth = calculateLevelHealth(attributes, gainLevels)
    
    increaseHealth(baseHealth + levelHealth - overlap)
end

modSettings.health:subscribe(async:callback(function(section, key)
    updateHealthConfig()
    updateHealth({}, 1)
end))

return {
    updateHealth = updateHealth
}