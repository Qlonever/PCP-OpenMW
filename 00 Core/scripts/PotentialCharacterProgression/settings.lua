-- Settings
local async = require('openmw.async')
local I = require('openmw.interfaces')
local input = require('openmw.input')
local storage = require('openmw.storage')

local info = require('scripts.PotentialCharacterProgression.info')

input.registerTrigger {
    key = 'Menu' .. info.name,
    l10n = info.name
}

I.Settings.registerPage {
    key = 'Page' .. info.name,
    l10n = info.name,
    name = 'PageName'
}

-- Debug settings

I.Settings.registerGroup {
    key = 'SettingsPlayer' .. info.name .. 'Debug',
    page = 'Page' .. info.name,
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

-- Balance settings

I.Settings.registerGroup {
    key = 'SettingsPlayer' .. info.name .. 'Balance',
    page = 'Page' .. info.name,
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
        }
    }
}

-- Basic player settings

I.Settings.registerGroup {
    key = 'SettingsPlayer' .. info.name,
    page = 'Page' .. info.name,
    l10n = info.name,
    name = 'SettingsPlayerName',
    permanentStorage = true,
    settings = {
        {
            key = 'MenuKey',
            renderer = info.name .. 'KeyBind',
            name = 'MenuKeyName',
            default = input.KEY.L
        },
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
            default = false
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
                min = 0
            }
        }
    }
}