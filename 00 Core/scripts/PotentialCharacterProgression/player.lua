-- The main logic and functions of this mod
local core = require('openmw.core')

local info = require('scripts.PotentialCharacterProgression.info')
local L = core.l10n(info.name)

if core.API_REVISION < info.minApiVersion then
    print(L('UpdateOpenMW'))
    return
end

local ambient = require('openmw.ambient')
local async = require('openmw.async')
local I = require('openmw.interfaces')
local input = require('openmw.input')
local self = require('openmw.self')
local storage = require('openmw.storage')
local types = require('openmw.types')
local ui = require('openmw.ui')
local util = require('openmw.util')

local Player = types.Player

local mwData = require('scripts.' .. info.name .. '.mwdata')
local PLui = require('scripts.' .. info.name .. '.ui')
local settings = require('scripts.' .. info.name .. '.settings')

local function contains(t, element)
  for _, value in pairs(t) do
    if value == element then
      return true
    end
  end
  return false
end

local function capital(text)
    return text:gsub('^%l', string.upper)
end

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Mod settings

local modSettings = {
    basic = storage.playerSection('SettingsPlayer' .. info.name),
    health = storage.playerSection('SettingsPlayer' .. info.name .. 'Health'),
    balance = storage.playerSection('SettingsPlayer' .. info.name .. 'Balance'),
    skill = storage.playerSection('SettingsPlayer' .. info.name .. 'Skill'),
    data = storage.playerSection('SettingsPlayer' .. info.name .. 'Data')
}

local healthSettings = {}

-- Game settings

local skillUpsPerLevel = core.getGMST('iLevelupTotal')
local levelHealthMult = core.getGMST('fLevelUpHealthEndMult')

-- Player data

local playerStats = Player.stats
local playerHealth = playerStats.dynamic.health
local playerAttributes = playerStats.attributes
local playerSkills = playerStats.skills

local function getPlayerRecords()
    local playerRecord = Player.record(self)
    return {
        class = Player.classes.record(playerRecord.class),
        race = Player.races.record(playerRecord.race),
        sex = (playerRecord.isMale and 'male') or 'female'
    }
end

-- Saved variables

-- Level-ups gained while this mod is active, important to track for health gain
local levelUps = 0
-- Total max health increase from this mod, important to track for external health/endurance gain
local totalHealthGained = 0
local experience = 0

local attributeData = {}

local skillData = {}

local function setAttributesValue(var, value)
    for i, attributeRecord in ipairs(core.stats.Attribute.records) do
        attributeData[attributeRecord.id][var] = value
    end
end

local function setSkillsValue(var, value)
    for i, skillRecord in ipairs(core.stats.Skill.records) do
        skillData[skillRecord.id][var] = value
    end
end

for i, attributeRecord in ipairs(core.stats.Attribute.records) do
    attributeData[attributeRecord.id] = {}
end

for i, skillRecord in ipairs(core.stats.Skill.records) do
    skillData[skillRecord.id] = {}
end

setAttributesValue('ups', 0)
setAttributesValue('potential', 0)

setSkillsValue('ups', 0)
setSkillsValue('upsCurLevel', 0)
setSkillsValue('upsLastLevels', 0)
setSkillsValue('peak', 0)

local totalSkillUpsCurLevel = 0

-- Runtime Variables

local isCharGenFinished = false
local startAttributes
local isLevelUp = true
local levelUpData







-- Debug stuff -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local function infoDump()
    for attributeId, attribute in pairs(attributeData) do
        print(attributeId .. ' increases: ' .. attribute.ups)
        print(attributeId .. ' potential: ' .. attribute.potential)
    end
    for skillId, skill in pairs(skillData) do
        print(skillId .. ' increases: ' .. skill.ups)
        print(skillId .. ' increases this level: ' .. skill.upsCurLevel)
        print(skillId .. ' increases last level: ' .. skill.upsLastLevels)
        print(skillId .. ' highest value: ' .. skill.peak)
    end
    print('Total skill increases this level: ' .. totalSkillUpsCurLevel)
    print('Level-ups: ' .. levelUps)
    print('Experience: ' .. experience)
    print('Total health gained: ' .. totalHealthGained)
end







-- Data management -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Completely reset data for the character, as if this mod was just installed
-- Menu scripts can't send player events, so use storage section subscriptions
modSettings.data:subscribe(async:callback(function(section, key)
    if key == 'ClearData' and modSettings.data:get(key) ~= 0 then
        setAttributesValue('ups', 0)
        setAttributesValue('potential', 0)

        setSkillsValue('ups', 0)
        setSkillsValue('upsCurLevel', 0)
        setSkillsValue('upsLastLevels', 0)
        setSkillsValue('peak', 0)

        levelUps = 0
        experience = 0
        totalHealthGained = 0
        totalSkillUpsCurLevel = 0
        isCharGenFinished = false
    end
end))







-- Health functions  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Update health settings
local function updateHealthSettings()
    healthSettings.isRetroactive = modSettings.health:get('RetroactiveHealth')
    healthSettings.isStartRetroactive = healthSettings.isRetroactive and modSettings.health:get('RetroactiveStartHealth')
    healthSettings.isGradual = healthSettings.isRetroactive and modSettings.health:get('GradualRetroactiveHealth')
    healthSettings.gradualIncrement = modSettings.health:get('GradualRetroactiveHealthIncrement')
    healthSettings.isCustom = modSettings.health:get('CustomHealth')
    healthSettings.customCoefficients = modSettings.health:get('CustomHealthCoefficients')
    healthSettings.customGainMult = modSettings.health:get('CustomGainMultiplier')
end

-- Increase max health, apply increase to current health as well
local function increaseHealth(healthIncrease)
    totalHealthGained = totalHealthGained + healthIncrease
    -- This can kill the player if they've messed around with character creation commands, which is pretty funny
    playerHealth(self).base = playerHealth(self).base + healthIncrease
    playerHealth(self).current = math.min(math.max(playerHealth(self).current + healthIncrease, 1), playerHealth(self).base)
end

-- Calculate starting attribute values, not factoring in birthsigns
local function getStartingAttributes()
    if not startAttributes then
        local playerRecords = getPlayerRecords()
        startAttributes = {}
        for attributeId, _ in pairs(attributeData) do
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
    for attributeId, _ in pairs(attributeData) do
        baseAttributes[attributeId] = playerAttributes[attributeId](self).base
    end
    return baseAttributes
end

-- Calculate weighted average for the custom health setting
local function calculateWeightedAverage(attributes)
    local average = 0
    local coefficientsSum = 0
    for attributeId, attribute in pairs(attributes) do
        average = average + attribute * healthSettings.customCoefficients[attributeId]
        coefficientsSum = coefficientsSum + math.max(healthSettings.customCoefficients[attributeId], 0)
    end
    if coefficientsSum == 0 then
        return 0
    else
        return average / coefficientsSum
    end
end

-- Calculate starting health under specified conditions
local function calculateStartHealth(isRetroactive, isCustom)
    local attributes
    if isRetroactive then
        attributes = getBaseAttributes()
    else
        attributes = getStartingAttributes()
    end
    if isCustom then
        return calculateWeightedAverage(attributes)
    else
        return (attributes.endurance + attributes.strength) * 0.5
    end
end

-- Given attribute values, calculate health gained from a specified number of level-ups
local function calculateLevelHealth(attributes, gainLevels)
    local levelMultiplier = gainLevels
    if healthSettings.isGradual then
        -- Use a triangular number (n * (n + 1) / 2) to calculate the growing attribute totals for gradual retroactive health
        -- These lines are overly-long but probably can't be simplified or meaningfully broken down further
        local totalledAttributes = attributes
        for attributeId, value in pairs(attributes) do
            local startValue = value - attributeData[attributeId].ups
            local growingLevels = math.min(math.ceil(attributeData[attributeId].ups / healthSettings.gradualIncrement), gainLevels)
            local difference = growingLevels * healthSettings.gradualIncrement - math.min(growingLevels * healthSettings.gradualIncrement, attributeData[attributeId].ups)
            totalledAttributes[attributeId] = growingLevels * (healthSettings.gradualIncrement * (growingLevels + 1) / 2 + startValue) - difference + (gainLevels - growingLevels) * value
        end   
        attributes = totalledAttributes
        levelMultiplier = 1
    end
    if healthSettings.isCustom then
        return calculateWeightedAverage(attributes) * healthSettings.customGainMult * levelMultiplier
    else
        return attributes.endurance * levelHealthMult * levelMultiplier
    end
end

-- Given attribute values and a number of level-ups, calculate health gain and optionally starting health
local function calculateHealthIncrease(attributes, isRetroactive, isStartRetroactive, gainLevels)
    if not attributes then
        attributes = getBaseAttributes()
    end

    local levelHealth = calculateLevelHealth(attributes, gainLevels)
    local startHealth = 0
    local base = 0

    if isRetroactive then
        startHealth = calculateStartHealth(isStartRetroactive, healthSettings.isCustom)
        base = calculateStartHealth(false, false) + totalHealthGained
    end

    increaseHealth(startHealth + levelHealth - base)
end







-- Menu functions -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Use skill increases to determine level-up art
local function getLevelUpClass()
    local highestScore = 0
    local highestClass = 'acrobat'
    
    -- Vanilla MW's calculation for this is needlessly complex, this is completely different
    local modifiers = {
        m  = 0.5,
        M  = 1.0,
        S  = 0.5,
        mS = 1.0,
        MS = 1.5
    }
    
    for class, data in pairs(mwData.classData) do
        local score = 0
        for skillId, tag in pairs(data) do
            score = score + skillData[skillId].upsLastLevels * modifiers[tag]
        end
        if score > highestScore then
            highestScore = score
            highestClass = class
        end
    end
        
    return highestClass
end

-- Show the level-up menu
-- When called by the normal level-up mechanics, increase level and give experience to distribute
local function showMenu()
    updateHealthSettings()

    if isLevelUp and isCharGenFinished then
        local levelsGained = math.floor(playerStats.level(self).progress / skillUpsPerLevel)
        -- Without this check, the player can (harmlessly) trigger the same level up over and over with the right timing
        if levelsGained > 0 then
            playerStats.level(self).progress = playerStats.level(self).progress - (levelsGained * skillUpsPerLevel)
            local nextLevel = playerStats.level(self).current + levelsGained
            playerStats.level(self).current = nextLevel
            levelUps = levelUps + levelsGained
            experience = experience + (levelsGained * modSettings.balance:get('ExperiencePerLevel'))
            ambient.streamMusic('Music/Special/MW_Triumph.mp3')
            
            levelUpData = {
                level = nextLevel,
                ups = levelsGained,
                class = getLevelUpClass()
            }

            setSkillsValue('upsLastLevels', 0)
        end
    end

    PLui.createMenu(levelUpData, attributeData, experience)
end

local function hideMenu()
    PLui.hideMenu()
    -- If leveled up or retroactive health gain enabled, calculate health gain with base attributes
    -- Other sources of attribute increases and health should be integrated correctly
    -- Do this in the hide function so it still triggers even if the player just closes the menu
    if levelUpData or healthSettings.isRetroactive then
        local gainLevels = (healthSettings.isRetroactive and levelUps) or levelUpData.ups
        calculateHealthIncrease(nil, healthSettings.isRetroactive, healthSettings.isStartRetroactive, gainLevels)
    end
    isLevelUp = true
    levelUpData = nil
end

I.UI.registerWindow('LevelUpDialog', showMenu, hideMenu)

local function finishMenu(data)
    for attributeId, uiAttribute in pairs(data.uiAttributes) do
        if not data.debugMode then
            attributeData[attributeId].potential = math.max(math.floor(uiAttribute.potential) - uiAttribute.ups, 0) + uiAttribute.potential - math.floor(uiAttribute.potential)
        end
        attributeData[attributeId].ups = attributeData[attributeId].ups + uiAttribute.ups
        playerAttributes[attributeId](self).base = playerAttributes[attributeId](self).base + uiAttribute.ups
    end
    
    -- If menu wasn't triggered by a level-up and retroactive gain is off, calculate health gain for 1 level
    -- Calculate only with menu attribute increases, don't integrate other attribute increases
    -- Do this in the finish menu event to avoid passing individual increase data to the hide function
    if not (isLevelUp or healthSettings.isRetroactive) then
        local healthAttributes = {}
        for attributeId, attribute in pairs(data.uiAttributes) do
            healthAttributes[attributeId] = attribute.ups
        end
        calculateHealthIncrease(healthAttributes, false, false, 1)
    end
    
    experience = data.uiExperience
    I.UI.removeMode('LevelUp')
end







-- Handlers -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Increase level progress and attribute potential for every skill increase 
-- Also track highest value for each skill, for use with the jail exploit setting
local function handleskillUps(skillId, source, options)
    options.levelUpProgress = nil
    if options.skillIncreaseValue and (options.levelUpAttribute or modSettings.skill:get('CustomSkillAttributes')) then
        -- Adjust the perceived skill increase based on settings and recorded peak value
        local skillIncrease = options.skillIncreaseValue
        local skillNewValue = skillIncrease + playerSkills[skillId](self).base
        if not modSettings.basic:get('JailExploit') then
            skillIncrease = skillNewValue - skillData[skillId].peak
        end
        skillIncrease = util.clamp(skillIncrease, 0, options.skillIncreaseValue)
        
        if skillIncrease == 0 then
            return true
        end
        
        -- Update stored skill data
        skillData[skillId].peak = math.max(skillNewValue, skillData[skillId].peak)
        skillData[skillId].ups = skillData[skillId].ups + skillIncrease
        skillData[skillId].upsCurLevel = skillData[skillId].upsCurLevel + skillIncrease
        totalSkillUpsCurLevel = totalSkillUpsCurLevel + skillIncrease

        local playerRecords = getPlayerRecords()

        -- Adjust the level progress/potential gained based on user settings
        local progressMult = modSettings.balance:get('LevelProgressPerSkill')
        local potentialMult = modSettings.balance:get('PotentialPerSkill')
        if contains(playerRecords.class.minorSkills, skillId) then
            progressMult = modSettings.balance:get('LevelProgressPerMinorSkill')
            potentialMult = modSettings.balance:get('PotentialPerMinorSkill')
        elseif contains(playerRecords.class.majorSkills, skillId) then
            progressMult = modSettings.balance:get('LevelProgressPerMajorSkill')
            potentialMult = modSettings.balance:get('PotentialPerMajorSkill')
        end
        
        options.levelUpProgress = skillIncrease * progressMult
        
        -- Extra logic for governing attribute reassignment
        -- Divide the earned potential between each attribute based on their set values
        if modSettings.skill:get('CustomSkillAttributes') then
            local total = 0
            local skillAttributes = modSettings.skill:get(capital(skillId) .. 'Attributes')
            for attributeId, value in pairs(skillAttributes) do
                total = total + value
            end
            for attributeId, value in pairs(skillAttributes) do
                attributeData[attributeId].potential = attributeData[attributeId].potential + skillIncrease * potentialMult * skillAttributes[attributeId] / total
            end  
        else
            attributeData[options.levelUpAttribute].potential = attributeData[options.levelUpAttribute].potential + skillIncrease * potentialMult
        end
        
        -- Prepare for level-up
        if totalSkillUpsCurLevel >= skillUpsPerLevel then
            totalSkillUpsCurLevel = totalSkillUpsCurLevel % skillUpsPerLevel
            for skillId, skill in pairs(skillData) do
                skillData[skillId].upsLastLevels = skillData[skillId].upsLastLevels + skillData[skillId].upsCurLevel
            end
            setSkillsValue('upsCurLevel', 0)
            skillData[skillId].upsLastLevels = skillData[skillId].upsLastLevels - totalSkillUpsCurLevel
            skillData[skillId].upsCurLevel = totalSkillUpsCurLevel
        end
    end
    return true
end

I.SkillProgression.addSkillLevelUpHandler(handleskillUps)

-- Record skill values when finishing character creation or when first loading this script on an existing character
local function finishCharGen()
    -- Update health with relevant settings
    updateHealthSettings()
    if healthSettings.isStartRetroactive then
        calculateHealthIncrease(false, true, true, 0)
    elseif healthSettings.isCustom then
        calculateHealthIncrease(getStartingAttributes(), true, false, 0)
    end

    for i, skillRecord in ipairs(core.stats.Skill.records) do
        skillData[skillRecord.id].peak = playerSkills[skillRecord.id](self).base
    end
    totalSkillUpsCurLevel = playerStats.level(self).progress % skillUpsPerLevel
    local keybind = input.getKeyName(modSettings.basic:get('MenuKey'))
    local charGenCallback = async:registerTimerCallback('charGenMessage', function()  ui.showMessage(L('StartUp', {keybind = keybind}), {showInDialogue = false}) end)
    async:newSimulationTimer(0.1, charGenCallback)
end

local function onUpdate()
    if not isCharGenFinished then
        if Player.isCharGenFinished(self) then
            isCharGenFinished = true
            finishCharGen()
        end
    end
end

-- Input handlers

local function levelMenuKey()
    local topMode = I.UI.modes[1]
    if isCharGenFinished then
        if contains(I.UI.modes, 'LevelUp') then
            I.UI.removeMode('LevelUp')
        elseif topMode == nil or topMode == 'Interface' then
            isLevelUp = false
            I.UI.addMode('LevelUp')
        end
    end
end

input.registerTriggerHandler('Menu' .. info.name, async:callback(levelMenuKey))

local function onKeyPress(key)
    if key.code == modSettings.basic:get('MenuKey') then
        input.activateTrigger('Menu' .. info.name)
    end
end

-- List of specific setting changes for each settings version
-- Used to inform player what settings they need to adjust after updating

local settingsChanges = {
    [1] = {},
    [2] = {'RetroactiveHealth'}
}

-- Save/load handlers

local function onLoad(data)
    -- Include values in save data to track breaking changes
    -- Settings version was accidentally left out of 1.0.0
    data.settingsVersion = data.settingsVersion or 1
    if info.settingsVersion > (data.settingsVersion) then
        local changeText = ''
        for i = data.settingsVersion + 1, info.settingsVersion, 1 do
            for _, settingKey in pairs(settingsChanges[i]) do
                changeText = changeText .. '\n' .. L(settingKey .. 'Name')
            end
        end
        if changeText ~= '' then
            ui.showMessage(L('SettingsVersionNew') .. changeText, {showInDialogue = false})
            print(L('SettingsVersionNew') .. changeText) 
        end
    elseif info.settingsVersion < (data.settingsVersion) then
        ui.showMessage(L('SettingsVersionOld'), {showInDialogue = false})
        print(L('SettingsVersionOld'))
    end

    if info.saveVersion > data.saveVersion then
        ui.showMessage(L('SaveVersionNew'), {showInDialogue = false})
        print(L('SaveVersionNew'))
    elseif info.saveVersion < data.saveVersion then
        ui.showMessage(L('SaveVersionOld'), {showInDialogue = false})
        print(L('SaveVersionOld'))
    end

    skillData = data.skillData or skillData
    attributeData = data.attributeData or attributeData
    levelUps = data.levelUps or levelUps
    experience = data.experience or experience
    totalHealthGained = data.totalHealthGained or totalHealthGained
    totalSkillUpsCurLevel = data.totalSkillUpsCurLevel or totalSkillUpsCurLevel
    isCharGenFinished = true
end

local function onSave()
    return {
        saveVersion = info.saveVersion,
        settingsVersion = info.settingsVersion,
        skillData = skillData,
        attributeData = attributeData,
        levelUps = levelUps,
        experience = experience,
        totalHealthGained = totalHealthGained,
        totalSkillUpsCurLevel = totalSkillUpsCurLevel,
    }
end

return {
    engineHandlers = {
        onUpdate = onUpdate,
        onKeyPress = onKeyPress,
        onLoad = onLoad,
        onSave = onSave
    },
    eventHandlers = {
        [info.name .. 'FinishMenu'] = finishMenu
    }
}