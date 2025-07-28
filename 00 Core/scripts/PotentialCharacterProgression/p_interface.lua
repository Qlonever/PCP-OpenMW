-- Interface for variables used over multiple scripts and save data
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
        savedVars[var] = savedVars[var] + value
    end
end

local function attributeGet(attributeId, var)
    return savedVars.attributeData[attributeId][var]
end

local function attributeSet(attributeId, var, value)
    savedVars.attributeData[attributeId][var] = value
end

local function attributeSetAll(var, value)
    for i, attributeRecord in ipairs(core.stats.Attribute.records) do
        savedVars.attributeData[attributeRecord.id][var] = value
    end
end

local function attributeInc(attributeId, var, value)
    if type(savedVars.attributeData[attributeId][var]) == 'number' then
        savedVars.attributeData[attributeId][var] = savedVars.attributeData[attributeId][var] + value
    end
end

local function attributeInc(attributeId, var, value)
    local getInc = type(value) == 'string'
    local varType = type(savedVars.attributeData[attributeId][var])
    if varType == 'number' then
        if getInc and type(savedVars.attributeData[attributeId][value]) == 'number' then
            value = savedVars.attributeData[attributeId][value]
        end
        savedVars.attributeData[attributeId][var] = savedVars.attributeData[attributeId][var] + value
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

local function skillSetAll(var, value)
    for i, skillRecord in ipairs(core.stats.Skill.records) do
        savedVars.skillData[skillRecord.id][var] = value
    end
end

local function skillInc(skillId, var, value)
    local getInc = type(value) == 'string'
    local varType = type(savedVars.skillData[skillId][var])
    if varType == 'number' then
        if getInc and type(savedVars.skillData[skillId][value]) == 'number' then
            value = savedVars.skillData[skillId][value]
        end
        savedVars.skillData[skillId][var] = savedVars.skillData[skillId][var] + value
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

    -- Level-ups gained while this mod is active, important to track for health gain
    savedVars.levelUps = 0
    -- Total max health increase from this mod, important to track for external health/attribute gain
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
    attributeIncAll = attributeSetAll,
    skillGet = skillGet,
    skillSet = skillSet,
    skillInc = skillInc,
    skillSetAll = skillSetAll,
    skillIncAll = skillIncAll,
    reset = initializeVars
}   