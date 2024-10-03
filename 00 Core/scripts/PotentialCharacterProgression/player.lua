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

local classData = require('scripts.' .. info.name .. '.classdata')
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

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Mod settings

local playerSettings = storage.playerSection('SettingsPlayer' .. info.name)
local balanceSettings = storage.playerSection('SettingsPlayer' .. info.name .. 'Balance')

-- Game settings

local skillUpsPerLevel = core.getGMST('iLevelupTotal')
local levelHealthMult = core.getGMST('fLevelUpHealthEndMult')

-- Player data

local playerStats = Player.stats
local playerAttributes = playerStats.attributes
local playerSkills = playerStats.skills

local function getPlayerRecords()
    return {
        class = Player.classes.record(Player.record(self).class),
        race = Player.races.record(Player.record(self).race),
        sex = (Player.record(self).isMale and 'male') or 'female'
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
    for attributeid, attribute in pairs(playerAttributes) do
        attributeData[attributeid][var] = value
    end
end

local function setSkillsValue(var, value)
    for skillid, skill in pairs(playerSkills) do
        skillData[skillid][var] = value
    end
end

for attributeid, attribute in pairs(playerAttributes) do
    attributeData[attributeid] = {}
end

for skillid, skill in pairs(playerSkills) do
    skillData[skillid] = {}
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
local isLevelUp = true
local levelUpData







-- Debug stuff -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local function infoDump()
    for attributeid, attribute in pairs(attributeData) do
        print(attributeid .. ' increases: ' .. attribute.ups)
        print(attributeid .. ' potential: ' .. attribute.potential)
    end
    for skillid, skill in pairs(skillData) do
        print(skillid .. ' increases: ' .. skill.ups)
        print(skillid .. ' increases this level: ' .. skill.upsCurLevel)
        print(skillid .. ' increases last level: ' .. skill.upsLastLevels)
        print(skillid .. ' highest value: ' .. skill.peak)
    end
    print('total skill increases this level: ' .. totalSkillUpsCurLevel)
    print('level-ups: ' .. levelUps)
    print('experience: ' .. experience)
end







-- Health functions  -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Increase max health, apply increase to current health as well
local function increaseHealth(healthIncrease)
    totalHealthGained = totalHealthGained + healthIncrease
    playerStats.dynamic.health(self).base = playerStats.dynamic.health(self).base + healthIncrease
    playerStats.dynamic.health(self).current = math.max(playerStats.dynamic.health(self).current + healthIncrease, 1)
end

-- Recalculate retroactive starting health
local function calculateRetroStartHealth()
    local playerRecords = getPlayerRecords()
    local currentEndurance = playerAttributes.endurance(self).base
    local currentStrength = playerAttributes.strength(self).base
    local initAttributes = {
        strength = playerRecords.race.attributes.strength[playerRecords.sex],
        endurance = playerRecords.race.attributes.endurance[playerRecords.sex]
    }
    for _, attributeid in pairs(playerRecords.class.attributes) do
        if attributeid == 'strength' or attributeid == 'endurance' then
            initAttributes[attributeid] = initAttributes[attributeid] + 10
        end
    end
    return (currentStrength + currentEndurance - initAttributes.strength - initAttributes.endurance) * 0.5
end







-- Menu functions -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Use skill increases to determine level-up art
local function getLevelUpClass()
    local highestScore = 0
    local highestClass = 'acrobat'
    
    for class, data in pairs(classData) do
        local score = 0
        for skillid, modifier in pairs(data) do
            score = score + skillData[skillid].upsLastLevels * modifier
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
    if isLevelUp then
        local levelsGained = math.floor(playerStats.level(self).progress / skillUpsPerLevel)
        -- Without this check, the player can (harmlessly) trigger the same level up over and over with the right timing
        if levelsGained > 0 then
            playerStats.level(self).progress = playerStats.level(self).progress - (levelsGained * skillUpsPerLevel)
            local nextLevel = playerStats.level(self).current + levelsGained
            playerStats.level(self).current = nextLevel
            levelUps = levelUps + levelsGained
            experience = experience + (levelsGained * balanceSettings:get('ExperiencePerLevel'))
            ambient.streamMusic('Music/Special/MW_Triumph.mp3')
            
            levelUpData = {
                level = nextLevel,
                ups = levelsGained,
                class = getLevelUpClass()
            }

            setSkillsValue('upsLastLevels', 0)
        end
    end

    -- Manually order attributes to match vanilla menus
    -- There is probably a better way to do this
    local attributeOrder = {
        strength = 1,
        intelligence = 2,
        willpower = 3,
        agility = 4,
        speed = 5,
        endurance = 6,
        personality = 7,
        luck = 8
    }

    local orderedAttributeData = {}
    local attributeCount = 8

    for attributeid, attribute in pairs(attributeData) do
        if attributeOrder[attributeid] then
            orderedAttributeData[attributeOrder[attributeid]] = {potential = attribute.potential, id = attributeid}
        else
            attributeCount = attributeCount + 1
            orderedAttributeData[attributeCount] = attribute
        end
    end

    PLui.createMenu(levelUpData, orderedAttributeData, experience, finishMenu)
end

local function hideMenu()
    PLui.hideMenu()
    -- If leveled up, remove all health granted by this mod, then recalculate with base attributes
    -- Other sources of endurance/strength and health should be integrated correctly
    -- Do this in the hide function so it still triggers even if the player just closes the menu
    if levelUpData then
        local currentEndurance = playerAttributes.endurance(self).base
        local healthIncrease = currentEndurance * levelHealthMult
        if playerSettings:get('RetroactiveHealth') then
            healthIncrease = healthIncrease * levelUps - totalHealthGained
            if playerSettings:get('RetroactiveStartHealth') then
                healthIncrease = healthIncrease + calculateRetroStartHealth()
            end
        else
            healthIncrease = healthIncrease * levelUpData.ups
        end
        increaseHealth(healthIncrease)
    end
    isLevelUp = true
    levelUpData = nil
end

I.UI.registerWindow('LevelUpDialog', showMenu, hideMenu)

local function finishMenu(data)
    for attributeid, uiAttribute in pairs(data.uiAttributes) do
        if not data.debugMode then
            attributeData[attributeid].potential = math.max(math.floor(uiAttribute.potential) - uiAttribute.ups, 0) + uiAttribute.potential - math.floor(uiAttribute.potential)
        end
        attributeData[attributeid].ups = attributeData[attributeid].ups + uiAttribute.ups
        playerAttributes[attributeid](self).base = playerAttributes[attributeid](self).base + uiAttribute.ups
    end
    
    -- If the menu wasn't triggered by a level-up, increase health based on endurance increases
    -- Other sources of endurance/strength won't be integrated until the next level-up
    -- Do this in the finish menu event so we don't have to pass individual increase data to the hide function
    if not isLevelUp then
        local healthIncrease = data.uiAttributes.endurance.ups * levelHealthMult
        if playerSettings:get('RetroactiveHealth') then
            healthIncrease = healthIncrease * levelUps
            if playerSettings:get('RetroactiveStartHealth') then
                healthIncrease = healthIncrease + (data.uiAttributes.endurance.ups + data.uiAttributes.strength.ups) * 0.5
            end
        end
        increaseHealth(healthIncrease)
    end
    
    experience = data.uiExperience
    I.UI.removeMode('LevelUp')
end







-- Handlers -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Increase level progress and attribute potential for every skill increase 
-- Also track highest value for each skill, for use with the jail exploit setting
local function handleskillUps(skillid, source, options)
    local skillIncrease = options.skillIncreaseValue
    local skillNewValue = skillIncrease + playerSkills[skillid](self).base
    if not playerSettings:get('JailExploit') then
        skillIncrease = util.clamp(skillNewValue - skillData[skillid].peak, 0, skillIncrease)
    end
    skillData[skillid].peak = math.max(skillNewValue, skillData[skillid].peak)
    skillData[skillid].ups = skillData[skillid].ups + skillIncrease
    skillData[skillid].upsCurLevel = skillData[skillid].upsCurLevel + skillIncrease
    totalSkillUpsCurLevel = totalSkillUpsCurLevel + skillIncrease
    options.levelUpProgress = skillIncrease

    local playerRecords = getPlayerRecords()

    local potentialMult = balanceSettings:get('PotentialPerSkill')
    if contains(playerRecords.class.minorSkills, skillid) then
        potentialMult = balanceSettings:get('PotentialPerMinorSkill')
    elseif contains(playerRecords.class.majorSkills, skillid) then
        potentialMult = balanceSettings:get('PotentialPerMajorSkill')
    end
    attributeData[options.levelUpAttribute].potential = attributeData[options.levelUpAttribute].potential + skillIncrease * potentialMult
    
    -- Prepare for level-up
    if totalSkillUpsCurLevel >= skillUpsPerLevel then
        totalSkillUpsCurLevel = totalSkillUpsCurLevel % skillUpsPerLevel
        for skillid, skill in pairs(skillData) do
            skillData[skillid].upsLastLevels = skillData[skillid].upsLastLevels + skillData[skillid].upsCurLevel
        end
        setSkillsValue('upsCurLevel', 0)
        skillData[skillid].upsLastLevels = skillData[skillid].upsLastLevels - totalSkillUpsCurLevel
        skillData[skillid].upsCurLevel = totalSkillUpsCurLevel
    end
end

I.SkillProgression.addSkillLevelUpHandler(handleskillUps)

-- Record skill values when finishing character creation or when first loading this script on an existing character
local function finishCharGen()
    -- Update health with relevant settings
    -- Have to check this because you can, in fact, level up before finishing character creation
    if levelUps == 0 then
        -- Birthsign bonuses should affect starting health immediately
        if playerSettings:get('RetroactiveHealth') and playerSettings:get('RetroactiveStartHealth') then
            local healthIncrease = calculateRetroStartHealth()
            increaseHealth(healthIncrease)
        end
    end

    for skillid, skill in pairs(playerSkills) do
        skillData[skillid].peak = skill(self).base
    end
    totalSkillUpsCurLevel = playerStats.level(self).progress % skillUpsPerLevel
    local keybind = input.getKeyName(playerSettings:get('MenuKey'))
    local charGenCallback = async:registerTimerCallback('charGenMessage', function() ui.showMessage(L('StartUp', {keybind = keybind}), {showInDialogue = false}) end)
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
    if key.code == playerSettings:get('MenuKey') then
        input.activateTrigger('Menu' .. info.name)
    end
end

-- Save/load handlers

local function onLoad(data)
    if info.saveVersion > data.saveVersion then
        ui.showMessage(L('SaveVersionNew'), {showInDialogue = false})
        print(L('SaveVersionNew'))
    elseif info.saveVersion < data.saveVersion then
        ui.showMessage(L('SaveVersionOld'), {showInDialogue = false})
        print(L('SaveVersionOld'))
    else
        if info.settingsVersion > (data.settingsVersion or 1) then
            ui.showMessage(L('SettingsVersionNew'), {showInDialogue = false})
            print(L('SettingsVersionNew'))
        elseif info.settingsVersion < (data.settingsVersion or 1) then
            ui.showMessage(L('SettingsVersionNew'), {showInDialogue = false})
            print(L('SettingsVersionOld'))
        end
        skillData = data.skillData
        attributeData = data.attributeData
        levelUps = data.levelUps
        experience = data.experience
        totalHealthGained = data.totalHealthGained
        totalSkillUpsCurLevel = data.totalSkillUpsCurLevel
    end
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
        FinishMenu = finishMenu
    }
}