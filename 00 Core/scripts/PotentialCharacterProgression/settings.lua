-- Settings
local async = require('openmw.async')
local core = require('openmw.core')
local I = require('openmw.interfaces')
local input = require('openmw.input')
local self = require('openmw.self')
local storage = require('openmw.storage')
local types = require('openmw.types')

local Player = types.Player

local info = require('scripts.PotentialCharacterProgression.info')
local mwData = require('scripts.' .. info.name .. '.mwdata')

local modSettings = {
    basic = storage.playerSection('SettingsPlayer' .. info.name),
    health = storage.playerSection('SettingsPlayer' .. info.name .. 'Health'),
    skill = storage.playerSection('SettingsPlayer' .. info.name .. 'Skill')
}

local function sortAlphabetical(a, b)
    return a:lower() < b:lower()
end

local function capital(text)
    return text:gsub('^%l', string.upper)
end

-- Can only set defaults for vanilla attributes
-- If future OpenMW features allow for adding attributes, this will help account for them
local function populateAttributes(defaults, value)
    local populatedAttributes = {}
    for attributeId, _ in pairs(Player.stats.attributes) do
        populatedAttributes[attributeId] = defaults[attributeId] or value
    end
    return populatedAttributes
end
        

-- Some custom settings renderers need to know what attributes there are
-- Can't access that information in menu scripts, so get it here and send it in an event
local eventData = {
    attributes = {}
}

for attributeId, _ in pairs(Player.stats.attributes) do
    eventData.attributes[attributeId] = {}
end

eventData.attributes = mwData.orderAttributes(eventData.attributes)

Player.sendMenuEvent(self, info.name .. 'RendererAttributes', eventData)

input.registerTrigger {
    key = 'Menu' .. info.name,
    l10n = info.name
}

I.Settings.registerPage {
    key = 'Page' .. info.name,
    l10n = info.name,
    name = 'PageName'
}

-- Basic settings

I.Settings.registerGroup {
    key = 'SettingsPlayer' .. info.name,
    page = 'Page' .. info.name,
    order = 1,
    l10n = info.name,
    name = 'SettingsBasicName',
    permanentStorage = true,
    settings = {
        {
            key = 'MenuKey',
            renderer = info.name .. 'KeyBind',
            name = 'MenuKeyName',
            default = input.KEY.L
        },
        {
            key = 'JailExploit',
            renderer = 'checkbox',
            name = 'JailExploitName',
            description = 'JailExploitDesc',
            default = false
        },
        {
            key = 'AttributeCap',
            renderer = 'number',
            name = 'AttributeCapName',
            description = 'AttributeCapDesc',
            default = 100,
            argument = {
                integer = true,
                min = 0,
                disabled = modSettings.basic:get('UniqueAttributeCap')
            }
        },
        {
            key = 'UniqueAttributeCap',
            renderer = 'checkbox',
            name = 'UniqueAttributeCapName',
            description = 'UniqueAttributeCapDesc',
            default = false
        },
        {
            key = 'UniqueAttributeCapValues',
            renderer = info.name .. 'UniqueCaps',
            name = 'UniqueAttributeCapValuesName',
            default = populateAttributes(
                {
                    strength = 100,
                    intelligence = 100,
                    willpower = 100,
                    agility = 100,
                    speed = 100,
                    endurance = 100,
                    personality = 100,
                    luck = 100
                }, 
                100),
            argument = {
                integer = true,
                min = 0,
                max = nil,
                disabled = not modSettings.basic:get('UniqueAttributeCap')
            }
        }
    }
}

-- Health settings

I.Settings.registerGroup {
    key = 'SettingsPlayer' .. info.name .. 'Health',
    page = 'Page' .. info.name,
    order = 2,
    l10n = info.name,
    name = 'SettingsHealthName',
    description = 'SettingsHealthDesc',
    permanentStorage = true,
    settings = {
        {
            key = 'RetroactiveHealth',
            renderer = 'checkbox',
            name = 'RetroactiveHealthName',
            description = 'RetroactiveHealthDesc',
            default = false
        },
        {
            key = 'RetroactiveStartHealth',
            renderer = 'checkbox',
            name = 'RetroactiveStartHealthName',
            description = 'RetroactiveStartHealthDesc',
            default = false,
            argument = {
                disabled = not modSettings.health:get('RetroactiveHealth')
            }
        },
        {
            key = 'CustomHealth',
            renderer = 'checkbox',
            name = 'CustomHealthName',
            description = 'CustomHealthDesc',
            default = false
        },
        {
            key = 'CustomHealthCoefficients',
            renderer = info.name .. 'Coefficients',
            name = 'CustomHealthCoefficientsName',
            description = 'CustomHealthCoefficientsDesc',
            default = populateAttributes(
                {
                    strength = 2,
                    intelligence = 0,
                    willpower = 1,
                    agility = 0,
                    speed = 0,
                    endurance = 4,
                    personality = 0,
                    luck = 0
                }, 
                0),
            argument = {
                integer = false,
                min = nil,
                max = nil,
                disabled = not modSettings.health:get('CustomHealth')
            }
        },
        {
            key = 'CustomGainMultiplier',
            renderer = 'number',
            name = 'CustomGainMultiplierName',
            description = 'CustomGainMultiplierDesc',
            default = 0.1,
            argument = {
                integer = false,
                min = 0,
                max = nil,
                disabled = not modSettings.health:get('CustomHealth')
            }
        }
    }
}

-- Balance settings

I.Settings.registerGroup {
    key = 'SettingsPlayer' .. info.name .. 'Balance',
    page = 'Page' .. info.name,
    order = 3,
    l10n = info.name,
    name = 'SettingsBalanceName',
    description = 'SettingsBalanceDesc',
    permanentStorage = true,
    settings = {
        {
            key = 'PotentialPerSkill',
            renderer = 'number',
            name = 'PotentialPerSkillName',
            default = 0.5,
            argument = {
                min = 0.0
            }
        },
        {
            key = 'PotentialPerMinorSkill',
            renderer = 'number',
            name = 'PotentialPerMinorSkillName',
            default = 0.5,
            argument = {
                min = 0.0
            }
        },
        {
            key = 'PotentialPerMajorSkill',
            renderer = 'number',
            name = 'PotentialPerMajorSkillName',
            default = 0.5,
            argument = {
                min = 0.0
            }
        },
        {
            key = 'ExperiencePerLevel',
            renderer = 'number',
            name = 'ExperiencePerLevelName',
            default = 15,
            argument = {
                integer = true,
                min = 0.0
            }
        },
        {
            key = 'ExperienceCost',
            renderer = 'number',
            name = 'ExperienceCostName',
            default = 1,
            argument = {
                integer = true,
                min = 0
            }
        },
        {
            key = 'ExperienceCostOver',
            renderer = 'number',
            name = 'ExperienceCostOverName',
            default = 5,
            argument = {
                integer = true,
                min = 0
            }
        },
        {
            key = 'ExperienceCostFavored',
            renderer = 'number',
            name = 'ExperienceCostFavoredName',
            default = 1,
            argument = {
                integer = true,
                min = 0
            }
        },
        {
            key = 'ExperienceCostFavoredOver',
            renderer = 'number',
            name = 'ExperienceCostFavoredOverName',
            default = 2,
            argument = {
                integer = true,
                min = 0
            }
        },
        {
            key = 'LevelProgressPerSkill',
            renderer = 'number',
            name = 'LevelProgressPerSkillName',
            default = 1,
            argument = {
                integer = true,
                min = 0
            }
        },
        {
            key = 'LevelProgressPerMinorSkill',
            renderer = 'number',
            name = 'LevelProgressPerMinorSkillName',
            default = 1,
            argument = {
                integer = true,
                min = 0
            }
        },
        {
            key = 'LevelProgressPerMajorSkill',
            renderer = 'number',
            name = 'LevelProgressPerMajorSkillName',
            default = 1,
            argument = {
                integer = true,
                min = 0
            }
        }
    }
}

-- Skill settings

local skillSettings = {
    {
        key = 'CustomSkillAttributes',
        renderer = 'checkbox',
        name = 'CustomSkillAttributesName',
        description = 'CustomSkillAttributesDesc',
        default = false
    }
}

local skillDefaults = {
    acrobatics  = {strength = 3, intelligence = 0, willpower = 0, agility = 1, speed = 2, endurance = 1, personality = 0, luck = 0},
    armorer     = {strength = 4, intelligence = 0, willpower = 0, agility = 0, speed = 0, endurance = 3, personality = 0, luck = 0},
    axe         = {strength = 4, intelligence = 0, willpower = 0, agility = 1, speed = 0, endurance = 2, personality = 0, luck = 0},
    bluntweapon = {strength = 3, intelligence = 0, willpower = 2, agility = 1, speed = 1, endurance = 0, personality = 0, luck = 0},
    longblade   = {strength = 3, intelligence = 0, willpower = 0, agility = 2, speed = 1, endurance = 1, personality = 0, luck = 0},
    alchemy     = {strength = 0, intelligence = 5, willpower = 0, agility = 0, speed = 0, endurance = 1, personality = 1, luck = 0},
    conjuration = {strength = 0, intelligence = 4, willpower = 1, agility = 0, speed = 0, endurance = 0, personality = 2, luck = 0},
    enchant     = {strength = 0, intelligence = 6, willpower = 0, agility = 0, speed = 0, endurance = 0, personality = 1, luck = 0},
    security    = {strength = 0, intelligence = 3, willpower = 0, agility = 3, speed = 0, endurance = 0, personality = 1, luck = 0},
    alteration  = {strength = 0, intelligence = 2, willpower = 5, agility = 0, speed = 0, endurance = 0, personality = 0, luck = 0},
    destruction = {strength = 0, intelligence = 1, willpower = 6, agility = 0, speed = 0, endurance = 0, personality = 0, luck = 0},
    mysticism   = {strength = 0, intelligence = 2, willpower = 4, agility = 0, speed = 0, endurance = 0, personality = 1, luck = 0},
    restoration = {strength = 0, intelligence = 1, willpower = 4, agility = 0, speed = 0, endurance = 0, personality = 2, luck = 0},
    block       = {strength = 0, intelligence = 0, willpower = 0, agility = 3, speed = 2, endurance = 2, personality = 0, luck = 0},
    lightarmor  = {strength = 0, intelligence = 0, willpower = 1, agility = 3, speed = 3, endurance = 0, personality = 0, luck = 0},
    marksman    = {strength = 2, intelligence = 1, willpower = 0, agility = 4, speed = 0, endurance = 0, personality = 0, luck = 0},
    sneak       = {strength = 0, intelligence = 0, willpower = 0, agility = 4, speed = 2, endurance = 0, personality = 1, luck = 0},
    athletics   = {strength = 0, intelligence = 0, willpower = 1, agility = 0, speed = 4, endurance = 2, personality = 0, luck = 0},
    handtohand  = {strength = 1, intelligence = 0, willpower = 0, agility = 1, speed = 4, endurance = 1, personality = 0, luck = 0},
    shortblade  = {strength = 1, intelligence = 0, willpower = 0, agility = 2, speed = 4, endurance = 0, personality = 0, luck = 0},
    unarmored   = {strength = 0, intelligence = 0, willpower = 2, agility = 0, speed = 3, endurance = 2, personality = 0, luck = 0},
    heavyarmor  = {strength = 3, intelligence = 0, willpower = 0, agility = 0, speed = 0, endurance = 4, personality = 0, luck = 0},
    mediumarmor = {strength = 2, intelligence = 0, willpower = 0, agility = 1, speed = 0, endurance = 4, personality = 0, luck = 0},
    spear       = {strength = 1, intelligence = 0, willpower = 0, agility = 1, speed = 1, endurance = 4, personality = 0, luck = 0},
    illusion    = {strength = 0, intelligence = 1, willpower = 1, agility = 0, speed = 0, endurance = 0, personality = 5, luck = 0},
    mercantile  = {strength = 0, intelligence = 1, willpower = 0, agility = 0, speed = 0, endurance = 0, personality = 6, luck = 0},
    speechcraft = {strength = 0, intelligence = 0, willpower = 0, agility = 0, speed = 0, endurance = 0, personality = 7, luck = 0},
}

local skillList = {}

for skillId, _ in pairs(Player.stats.skills) do
    table.insert(skillList, skillId)
end

table.sort(skillList, sortAlphabetical)

for _, skillId in pairs(skillList) do
    table.insert(skillSettings, {
        key = capital(skillId) .. 'Attributes',
        renderer = info.name .. 'SkillAttributes',
        name = core.getGMST('sSkill' .. capital(skillId)) .. '  ',
        default = populateAttributes(skillDefaults[skillId] or {}, 0),
        argument = {integer = false, min = 0, max = nil, disabled = not modSettings.skill:get('CustomSkillAttributes')}
    })
end

I.Settings.registerGroup {
    key = 'SettingsPlayer' .. info.name .. 'Skill',
    page = 'Page' .. info.name,
    order = 4,
    l10n = info.name,
    name = 'SettingsSkillName',
    permanentStorage = true,
    settings = skillSettings
}

-- Debug settings

I.Settings.registerGroup {
    key = 'SettingsPlayer' .. info.name .. 'Debug',
    page = 'Page' .. info.name,
    order = 5,
    l10n = info.name,
    name = 'SettingsDebugName',
    permanentStorage = true,
    settings = {
        {
            key = 'DebugMode',
            renderer = 'checkbox',
            name = 'DebugModeName',
            description = 'DebugModeDesc',
            default = false
        }
    }
}

-- Dependent Settings

local function dependentSetting(dependentKey, key, value, section, sectionKey, changedKey)
    if changedKey == key then
        local disabled = true
        if section:get(key) == value then
            disabled = false
        end
        I.Settings.updateRendererArgument(sectionKey, dependentKey, {disabled = disabled})
    end
end

modSettings.basic:subscribe(async:callback(function(section, key)
    dependentSetting('AttributeCap', 'UniqueAttributeCap', false, modSettings.basic, 'SettingsPlayer' .. info.name, key)
    dependentSetting('UniqueAttributeCapValues', 'UniqueAttributeCap', true, modSettings.basic, 'SettingsPlayer' .. info.name, key)
end))

modSettings.health:subscribe(async:callback(function(section, key)
    dependentSetting('RetroactiveStartHealth', 'RetroactiveHealth', true, modSettings.health, 'SettingsPlayer' .. info.name .. 'Health', key)
    dependentSetting('CustomHealthCoefficients', 'CustomHealth', true, modSettings.health, 'SettingsPlayer' .. info.name .. 'Health', key)
    dependentSetting('CustomGainMultiplier', 'CustomHealth', true, modSettings.health, 'SettingsPlayer' .. info.name .. 'Health', key)
end))

modSettings.skill:subscribe(async:callback(function(section, key)
    for skillId, _ in pairs(types.NPC.stats.skills) do
        dependentSetting(capital(skillId) .. 'Attributes', 'CustomSkillAttributes', true, modSettings.skill, 'SettingsPlayer' .. info.name .. 'Skill', key)
    end
end))