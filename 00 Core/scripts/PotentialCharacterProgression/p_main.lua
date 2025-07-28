-- The main logic and functions of this mod
local core = require('openmw.core')

local info = require('scripts.PotentialCharacterProgression.info')

local IName = info.interfaceName
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

local mwData = require('scripts.' .. info.name .. '.p_mwdata')
local PCPui = require('scripts.' .. info.name .. '.p_ui')
local settings = require('scripts.' .. info.name .. '.p_settings')
local interface = require('scripts.' .. info.name .. '.p_interface')
local healthFunctions = require('scripts.' .. info.name .. '.p_health')

local function contains(t, element)
  for _, value in pairs(t) do
    if value == element then
      return true
    end
  end
  return false
end

local function C(text)
    return text:gsub('^%l', string.upper)
end

-- Player data

local Player = types.Player

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







-- Script constants/variables -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Game settings

local gameSettings = {
    skillUpsPerLevel = core.getGMST('iLevelupTotal')
}

-- Mod settings

local modSettings = {
    basic = storage.playerSection('SettingsPlayer' .. info.name .. 'Basic'),
    balance = storage.playerSection('SettingsPlayer' .. info.name .. 'Balance'),
    skill = storage.playerSection('SettingsPlayer' .. info.name .. 'Skill'),
    data = storage.playerSection('SettingsPlayer' .. info.name .. 'Data')
}

-- Runtime Variables

local existingSave = true
local isCharGenFinished = false
local startAttributes
local levelUpData = {
    isLevelUp = true
}

local debugEnabled = false







-- Debug stuff -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local function infoDump()
    if not debugEnabled then return end
    for attributeId, attribute in pairs(I[IName].get('attributeData')) do
        print(attributeId .. ' increases: ' .. attribute.ups)
        print(attributeId .. ' potential: ' .. attribute.potential)
    end
    for skillId, skill in pairs(I[IName].get('skillData')) do
        print(skillId .. ' increases: ' .. skill.ups)
        print(skillId .. ' increases this level: ' .. skill.upsCurLevel)
        print(skillId .. ' increases last level: ' .. skill.upsLastLevels)
        print(skillId .. ' highest value: ' .. skill.peak)
    end
    print('Total skill increases this level: ' .. I[IName].get('totalSkillUpsCurLevel'))
    print('Level-ups: ' .. I[IName].get('levelUps'))
    print('Experience: ' .. I[IName].get('experience'))
    print('Total health gained: ' .. I[IName].get('totalHealthGained'))
end

local function debugPrint(text)
    if not debugEnabled then return end
    print(text)
end







-- Data management -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Completely reset data for the character, as if this mod was just installed
-- Menu scripts can't send player events, so use storage section subscriptions
modSettings.data:subscribe(async:callback(function(section, key)
    if key == 'ClearData' and modSettings.data:get(key) ~= 0 then
        I[IName].reset()
        existingSave = true
        isCharGenFinished = false
    end
end))







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
            score = score + I[IName].skillGet(skillId, 'upsLastLevels') * modifiers[tag]
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
    if levelUpData.isLevelUp and isCharGenFinished then
        local levelsGained = math.floor(playerStats.level(self).progress / gameSettings.skillUpsPerLevel)
        -- Without this check, the player can (harmlessly) trigger the same level up over and over with the right timing
        if levelsGained > 0 then
            playerStats.level(self).progress = playerStats.level(self).progress - (levelsGained * gameSettings.skillUpsPerLevel)
            local nextLevel = playerStats.level(self).current + levelsGained
            playerStats.level(self).current = nextLevel
            I[IName].inc('levelUps', levelsGained)
            I[IName].inc('experience', levelsGained * modSettings.balance:get('ExperiencePerLevel'))
            
            levelUpData.level = nextLevel
            levelUpData.ups = levelsGained
            levelUpData.class = getLevelUpClass()
            
            I[IName].skillSetAll('upsLastLevels', 0)
            -- PCP doesn't use this value, but reset it like normal for additional compatibility when uninstalling
            for i, attributeRecord in ipairs(core.stats.Attribute.records) do
                playerStats.level(self).skillIncreasesForAttribute[attributeRecord.id] = 0
            end
            ambient.streamMusic('Music/Special/MW_Triumph.mp3')
        end
    end
    
    PCPui.createMenu(levelUpData)
end

local function hideMenu()
    PCPui.hideMenu()
    -- Update health when closing the menu
    healthFunctions.updateHealth(levelUpData.attributeUps or {}, levelUpData.ups or 1)
    
    levelUpData = {
        isLevelUp = true
    }
end

I.UI.registerWindow('LevelUpDialog', showMenu, hideMenu)

local function finishMenu(data)
    levelUpData.attributeUps = {}
    for attributeId, uiAttribute in pairs(data.uiAttributes) do
        if not data.debugMode then
            I[IName].attributeSet(attributeId, 'potential', math.max(math.floor(uiAttribute.potential) - uiAttribute.ups, 0) + uiAttribute.potential - math.floor(uiAttribute.potential))
        end
        I[IName].attributeInc(attributeId, 'ups', uiAttribute.ups)
        playerAttributes[attributeId](self).base = playerAttributes[attributeId](self).base + uiAttribute.ups
        levelUpData.attributeUps[attributeId] = uiAttribute.ups
    end
    
    I[IName].set('experience', data.uiExperience)
    I.UI.removeMode('LevelUp')
end







-- Handlers -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

-- Increase attributes' potential given an increase value, governing attribute, and (optionally) skill ID
local function increasePotential(increase, attributeId, skillId)
    local playerRecords = getPlayerRecords()
    
    -- Adjust the level progress/potential gained based on user settings
    local potentialMult = modSettings.balance:get('PotentialPerSkill')
    if skillId ~= nil then
        if contains(playerRecords.class.minorSkills, skillId) then
            potentialMult = modSettings.balance:get('PotentialPerMinorSkill')
        elseif contains(playerRecords.class.majorSkills, skillId) then
            potentialMult = modSettings.balance:get('PotentialPerMajorSkill')
        end
    end
    
    -- Extra logic for governing attribute reassignment
    -- Divide the earned potential between each attribute based on their set values
    if modSettings.skill:get('CustomSkillAttributes') and skillId ~= nil then
        local total = 0
        local skillAttributes = modSettings.skill:get(C(skillId) .. 'Attributes')
        for attributeId, value in pairs(skillAttributes) do
            total = total + value
        end
        for attributeId, value in pairs(skillAttributes) do
            I[IName].attributeInc(attributeId, 'potential', increase * potentialMult * skillAttributes[attributeId] / total)
        end  
    else
        I[IName].attributeInc(attributeId, 'potential', increase * potentialMult)
    end
end

-- Increase level progress and attribute potential for every skill increase 
-- Also track highest value for each skill, for use with the jail exploit setting
local function handleskillUps(skillId, source, options)
    options.levelUpProgress = nil
    if options.skillIncreaseValue and (options.levelUpAttribute or modSettings.skill:get('CustomSkillAttributes')) then
        -- Adjust the perceived skill increase based on settings and recorded peak value
        -- Also account for built-in handlers fraudulently triggering skillLevelUps
        local skillBase = playerSkills[skillId](self).base
        local skillNewBase = options.skillIncreaseValue + skillBase
        local skillCap = 100
        if I.CSC then
            skillCap = I.CSC.getSkillCap(skillId)
        end
        if skillCap > 0 then
            skillNewBase = math.min(skillNewBase, skillCap)
        end
        if not modSettings.basic:get('JailExploit') then
            skillBase = math.max(skillBase, I[IName].skillGet(skillId, 'peak'))
        end
        local skillIncrease = skillNewBase - skillBase
        
        if skillIncrease <= 0 then
            return true
        end
        
        -- Update stored skill data
        I[IName].skillSet(skillId, 'peak', math.max(skillNewBase, I[IName].skillGet(skillId, 'peak')))
        I[IName].skillInc(skillId, 'ups', skillIncrease)
        I[IName].skillInc(skillId, 'upsCurLevel', skillIncrease)
        I[IName].inc('totalSkillUpsCurLevel', skillIncrease)
        
        local playerRecords = getPlayerRecords()
        
        -- Adjust the level progress/potential gained based on user settings
        local progressMult = modSettings.balance:get('LevelProgressPerSkill')
        if contains(playerRecords.class.minorSkills, skillId) then
            progressMult = modSettings.balance:get('LevelProgressPerMinorSkill')
        elseif contains(playerRecords.class.majorSkills, skillId) then
            progressMult = modSettings.balance:get('LevelProgressPerMajorSkill')
        end
        
        increasePotential(skillIncrease, options.levelUpAttribute, skillId)
        
        options.levelUpProgress = skillIncrease * progressMult
        
        -- Prepare for level-up
        if I[IName].get('totalSkillUpsCurLevel') >= gameSettings.skillUpsPerLevel then
            I[IName].skillIncAll('upsLastLevels', 'upsCurLevel')
            I[IName].skillSetAll('upsCurLevel', 0)
            -- Account for skills increasing by more than 1, may need to divide increases between two character levels
            local totalUps = I[IName].get('totalSkillUpsCurLevel') % gameSettings.skillUpsPerLevel
            I[IName].set('totalSkillUpsCurLevel', totalUps)
            I[IName].skillInc(skillId, 'upsLastLevels', -1 * totalUps)
            I[IName].skillSet(skillId, 'upsCurLevel', totalUps)
        end
    end
    return true
end

I.SkillProgression.addSkillLevelUpHandler(handleskillUps)

-- Record skill values when finishing character creation or when first loading this script on an existing character
local function finishCharGen()
    -- Update health with relevant settings
    healthFunctions.updateHealth()
    
    for i, skillRecord in ipairs(core.stats.Skill.records) do
        I[IName].skillSet(skillRecord.id, 'peak', playerSkills[skillRecord.id](self).base)
    end
    local levelProgress = playerStats.level(self).progress
    I[IName].set('totalSkillUpsCurLevel', levelProgress % gameSettings.skillUpsPerLevel)
    
    -- Give potential for skill increases before this mod was installed
    -- Can't identify which skills were increased, only their governing attributes
    if existingSave then
        for i, attributeRecord in ipairs(core.stats.Attribute.records) do
            local attributeId = attributeRecord.id
            local governedSkillUps = playerStats.level(self).skillIncreasesForAttribute[attributeId]
            local difference = math.min(governedSkillUps, levelProgress)
            levelProgress = levelProgress - difference
            increasePotential(difference, attributeId)
        end
    end
    
    local keybind = input.getKeyName(modSettings.basic:get('MenuKey'))
    local charGenCallback = async:registerTimerCallback('charGenMessage', function()  ui.showMessage(L('StartUp', {keybind = keybind}), {showInDialogue = false}) end)
    async:newSimulationTimer(0.1, charGenCallback)
end

local function onUpdate()
    if not isCharGenFinished then
        if Player.isCharGenFinished(self) then
            isCharGenFinished = true
            finishCharGen()
        else
            existingSave = false
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
            levelUpData.isLevelUp = false
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

-- Save/load handlers

local function onLoad(data)
    -- Include version in save data to track breaking changes
    if info.saveVersion > data.saveVersion then
        ui.showMessage(L('SaveVersionNew'), {showInDialogue = false})
        print(L('SaveVersionNew'))
    elseif info.saveVersion < data.saveVersion then
        ui.showMessage(L('SaveVersionOld'), {showInDialogue = false})
        print(L('SaveVersionOld'))
    end
    data.saveVersion = nil
    data.settingsVersion = nil
    
    for k, v in pairs(data) do
        I[IName].set(k, v)
    end
    
    existingSave = false
    isCharGenFinished = true
end

local function onSave()
    return {
        saveVersion = info.saveVersion,
        settingsVersion = info.settingsVersion,
        skillData = I[IName].get('skillData'),
        attributeData = I[IName].get('attributeData'),
        levelUps = I[IName].get('levelUps'),
        experience = I[IName].get('experience'),
        totalHealthGained = I[IName].get('totalHealthGained'),
        totalSkillUpsCurLevel = I[IName].get('totalSkillUpsCurLevel'),
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
    },
    interfaceName = IName,
    interface = interface
}