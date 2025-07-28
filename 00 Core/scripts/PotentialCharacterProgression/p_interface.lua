-- Interface for variables used over multiple scripts and save data

-- Variables included in interface:
    -- KEY ...................... DESCRIPTION
    
    -- levelUps ................. The number of levels the player has gained with this mod, used by the "Retroactive Health Gain" setting
    -- experience ............... The number of experience points the player currently has to spend in the potential menu
    -- totalHealthGained ........ The total amount this mod has added to the player's max health, does not include health granted by vanilla character creation or from other sources
    -- totalSkillUpsCurLevel .... The current number of skill increases contributing towards gaining another level-up, does not include skill increases contributing to queued level-ups
    -- attributeData ............ Data tables containing variables for each attribute, accessible by attribute record IDs
        -- ups ...................... The total points the attribute has gained from this mod, used by the "Realistic Retroactive Health Gain" setting
        -- potential ................ The potential of the attribute, stored as points over the attribute's base value rather than the limit visible in the menu
    -- skillData ................ Data tables containing variables for each skill, accessible by skill record IDs
        -- ups ...................... The total points the skill has been increased by while this mod was installed, currently unused but still tracked
        -- upsCurLevel .............. The number of increases contributed by the skill towards gaining another level-up, used to select level-up class art
        -- upsLastLevels ............ The number of increases contributed by the skill towards queued level-ups, used to select level-up class art
        -- peak ..................... The highest value reached by the skill while this mod was installed, used by the "Allow Jail Time Exploit" setting
        
-- Interface functions:
    -- FUNCTION(args) ........................... DESCRIPTION
    
    -- get(key) ................................. Returns the variable with the given key
    -- set(key, value) .......................... Sets the variable with the given key equal to the value
    -- inc(key, value) .......................... Increases the variable with the given key by the value, returns the incremented value
    -- attributeGet(attributeId, key) ........... Returns the attribute's variable with the given key
    -- attributeSet(attributeId, key, value) .... Sets the attribute's variable with the given key equal to the value
    -- attributeInc(attributeId, key, value) .... Increases the attribute's variable with the given key by the value, returns the incremented value
    -- attributeSetAll(key, value) .............. Sets the variable with the given key equal to the value for every attribute
    -- attributeIncAll(key, value) .............. Increases the variable with the given key by the value for every attribute
    -- skillGet(skillId, key) ................... Returns the skill's variable with the given key
    -- skillSet(skillId, key, value) ............ Sets the skill's variable with the given key equal to the value
    -- skillInc(skillId, key, value) ............ Increases the skill's variable with the given key by the value, returns the incremented value
    -- skillSetAll(key, value) .................. Sets the variable with the given key equal to the value for every skill
    -- skillIncAll(key, value) .................. Increases the variable with the given key by the value for every skill
    -- reset() .................................. Resets every variable to its initial value
    
    -- Note: Inc functions can also accept another key in place of a value, which will increase the first variable by the second
    
local core = require('openmw.core')

local info = require('scripts.PotentialCharacterProgression.info')

-- Saved variables

local savedVars = {
    attributeData = {},
    skillData = {}
}

-- Variable get/set functions

local function get(var) 
    return savedVars[var] 
end

local function set(var, value)
    savedVars[var] = value
end

local function inc(var, value)
    if type(savedVars[var]) == 'number' then
        local incValue = savedVars[var] + value
        savedVars[var] = incValue
        return incValue
    end
end

local function attributeGet(attributeId, var)
    return savedVars.attributeData[attributeId][var]
end

local function attributeSet(attributeId, var, value)
    savedVars.attributeData[attributeId][var] = value
end

local function attributeInc(attributeId, var, value)
    local getInc = type(value) == 'string'
    local varType = type(savedVars.attributeData[attributeId][var])
    if varType == 'number' then
        if getInc and type(savedVars.attributeData[attributeId][value]) == 'number' then
            value = savedVars.attributeData[attributeId][value]
        end
        local incValue = savedVars.attributeData[attributeId][var] + value
        savedVars.attributeData[attributeId][var] = incValue
        return incValue
    end
end

local function attributeSetAll(var, value)
    for i, attributeRecord in ipairs(core.stats.Attribute.records) do
        savedVars.attributeData[attributeRecord.id][var] = value
    end
end

local function attributeIncAll(var, value)
    local getInc = type(value) == 'string'
    for i, attributeRecord in ipairs(core.stats.Attribute.records) do
        local attributeId = attributeRecord.id
        local varType = type(savedVars.attributeData[attributeId][var])
        if varType == 'number' then
            if getInc and type(savedVars.attributeData[attributeId][value]) == 'number' then
                value = savedVars.attributeData[attributeId][value]
            end
            savedVars.attributeData[attributeId][var] = savedVars.attributeData[attributeId][var] + value
        end
    end
end

local function skillGet(skillId, var)
    return savedVars.skillData[skillId][var]
end

local function skillSet(skillId, var, value)
    savedVars.skillData[skillId][var] = value
end

local function skillInc(skillId, var, value)
    local getInc = type(value) == 'string'
    local varType = type(savedVars.skillData[skillId][var])
    if varType == 'number' then
        if getInc and type(savedVars.skillData[skillId][value]) == 'number' then
            value = savedVars.skillData[skillId][value]
        end
        local incValue = savedVars.skillData[skillId][var] + value
        savedVars.skillData[skillId][var] = incValue
        return incValue
    end
end

local function skillSetAll(var, value)
    for i, skillRecord in ipairs(core.stats.Skill.records) do
        savedVars.skillData[skillRecord.id][var] = value
    end
end

local function skillIncAll(var, value)
    local getInc = type(value) == 'string'
    for i, skillRecord in ipairs(core.stats.Skill.records) do
        local skillId = skillRecord.id
        local varType = type(savedVars.skillData[skillId][var])
        if varType == 'number' then
            if getInc and type(savedVars.skillData[skillId][value]) == 'number' then
                value = savedVars.skillData[skillId][value]
            end
            savedVars.skillData[skillId][var] = savedVars.skillData[skillId][var] + value
        end
    end
end

-- Initialize attribute/skill data

for i, attributeRecord in ipairs(core.stats.Attribute.records) do
    savedVars.attributeData[attributeRecord.id] = {}
end

for i, skillRecord in ipairs(core.stats.Skill.records) do
    savedVars.skillData[skillRecord.id] = {}
end

local function initializeVars()
    attributeSetAll('ups', 0)
    attributeSetAll('potential', 0)

    skillSetAll('ups', 0)
    skillSetAll('upsCurLevel', 0)
    skillSetAll('upsLastLevels', 0)
    skillSetAll('peak', 0)

    savedVars.levelUps = 0
    savedVars.totalHealthGained = 0
    savedVars.experience = 0
    savedVars.totalSkillUpsCurLevel = 0
end

initializeVars()

return {
    version = info.interfaceVersion,
    get = get,
    set = set,
    inc = inc,
    attributeGet = attributeGet,
    attributeSet = attributeSet,
    attributeInc = attributeInc,
    attributeSetAll = attributeSetAll,
    attributeIncAll = attributeIncAll,
    skillGet = skillGet,
    skillSet = skillSet,
    skillInc = skillInc,
    skillSetAll = skillSetAll,
    skillIncAll = skillIncAll,
    reset = initializeVars
}   