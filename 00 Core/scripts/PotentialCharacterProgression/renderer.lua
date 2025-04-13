local async = require('openmw.async')local I = require('openmw.interfaces')
local core = require('openmw.core')
local input = require('openmw.input')
local ui = require('openmw.ui')
local util = require('openmw.util')

local info = require('scripts.PotentialCharacterProgression.info')
local L = core.l10n(info.name)

if core.API_REVISION < info.minApiVersion then
    return
end

local myui = require('scripts.' .. info.name .. '.myui')

local v2 = util.vector2

local function capital(text)
    return text:gsub('^%l', string.upper)
end


local function receiveAttributeData(eventData)
    local attributesList = {}
    
    for i, attribute in ipairs(eventData.attributes) do
        attributesList[i] = attribute.id
    end

    local gameSettings = {}

    for _, attributeId in pairs(attributesList) do
        gameSettings[attributeId .. 'Name'] = core.getGMST('sAttribute' .. capital(attributeId))
    end

    local function disable(disabled, layout, collapse)
        --Collapsible renderers would be nice, but currently resizing stuff breaks the settings page
        collapse = false
        if disabled then
            local disabledContent = nil
            if not collapse then 
                disabledContent = ui.content {
                        layout
                    }
            end
            return {
                template = myui.templates.disabled,
                content = disabledContent
            }
        else
            return layout
        end
    end

    I.Settings.registerRenderer(info.name .. 'KeyBind', function(value, set)
        local rendererLayout
        rendererLayout = {
            type = ui.TYPE.Container,
            template = I.MWUI.templates.box,
            content = ui.content {
                {
                    type = ui.TYPE.Container,
                    template = myui.padding(4, 4),
                    content = ui.content {
                        {
                            type = ui.TYPE.Text,
                            template = I.MWUI.templates.textNormal,
                            props = {autoSize = true, textAlignH = ui.ALIGNMENT.End, text = value and input.getKeyName(value) or 'Not Bound'},
                            events = {
                                keyPress = async:callback(function(event)
                                    if event.code == input.KEY.Escape then
                                        return
                                    elseif event.code == input.KEY.Delete or event.code == input.KEY.Backspace then
                                        set(nil)
                                    else
                                        set(event.code)
                                    end
                                end)
                            }
                        }
                    }
                }
            }
        }
        return rendererLayout
    end)

    -- Unused selection renderer
    I.Settings.registerRenderer(info.name .. 'Select', function(value, set, argument)
        local optionsContent = ui.content {}
        for _, item in pairs(argument.items) do
            local itemColor = nil
            if tostring(item) == tostring(value) then
                itemColor = myui.interactiveTextColors.active.default
            end
            local itemLayout = {
                type = ui.TYPE.Container,
                template = myui.padding(0, 2),
                content = ui.content {
                    {
                        type = ui.TYPE.Text,
                        template = I.MWUI.templates.textNormal,
                        props = {text = L(tostring(item)), textColor = itemColor, textAlignV = ui.ALIGNMENT.Center},
                        events = {
                            mouseClick = async:callback(function(mouseEvent, data)
                                set(tostring(item))
                            end)
                        }
                    }
                }
            }
            optionsContent:add(itemLayout)
        end
        local rendererLayout = {
            type = ui.TYPE.Container,
            template = I.MWUI.templates.boxSolid,
            props = {visible = true},
            content = ui.content {
                {
                    type = ui.TYPE.Container,
                    template = myui.padding(6,2),
                    content = ui.content {
                        {
                            type = ui.TYPE.Flex,
                            props = {},
                            content = optionsContent
                        }
                    }
                }
            }
        }
        return disable(argument.disabled, rendererLayout)
    end)

    -- Modified version of default number renderer
    local function validateNumber(text, argument)
        local number = tonumber(text)
        if not number then return end
        if argument.min and number < argument.min then return end
        if argument.max and number > argument.max then return end
        if argument.integer and math.floor(number) ~= number then return end
        return number
    end

    local function createAttributeField(value, set, argument, attributeId, size)
        return {
            type = ui.TYPE.Container,
            template = I.MWUI.templates.box,
            content = ui.content {
                {
                    type = ui.TYPE.Container,
                    template = myui.padding(2, 2),
                    content = ui.content {
                        {
                            template = I.MWUI.templates.textEditLine,
                            props = {
                                text = tostring(value[attributeId] or 0),
                                size = size,
                            },
                            events = {
                                textChanged = async:callback(function(text)
                                    lastInput = text
                                end),
                                focusLoss = async:callback(function()
                                    if not lastInput then return end
                                    local number = validateNumber(lastInput, argument)
                                    lastInput = nil
                                    if number and number ~= value then
                                        value[attributeId] = number
                                    end
                                    set(value)
                                end)
                            }
                        }
                    }
                }
            }
        }
    end

    -- Renderer for unique attribute caps
    local function createUniqueCapField(value, set, argument, attributeId)
        local lastInput = nil
        return {
            type = ui.TYPE.Flex,
            props = {horizontal = true, arrange = ui.ALIGNMENT.Center},
            content = ui.content {
                {
                    type = ui.TYPE.Text,
                    template = I.MWUI.templates.textNormal,
                    props = {text = gameSettings[attributeId .. 'Name'] .. ' '}
                },
                createAttributeField(value, set, argument, attributeId, v2(60, 0))
            }
        }
    end

    I.Settings.registerRenderer(info.name .. 'UniqueCaps', function(value, set, argument)
        local rendererLayout
        rendererLayout = {
            type = ui.TYPE.Flex,
            props = {arrange = ui.ALIGNMENT.End},
            content = ui.content {}
        }
        for _, attributeId in pairs(attributesList) do
            rendererLayout.content:add(createUniqueCapField(value, set, argument, attributeId))
        end
        return disable(argument.disabled, rendererLayout, true)
    end)

    -- Renderer for custom health coefficients
    local function createCoefficientField(value, set, argument, attributeId, first)
        local lastInput = nil
        local plus = {}
        if not first then
            plus = {
                type = ui.TYPE.Text,
                template = I.MWUI.templates.textNormal,
                props = {text = '+ '}
            }
        end
        local rendererLayout = {
            type = ui.TYPE.Flex,
            props = {horizontal = true, arrange = ui.ALIGNMENT.Center},
            content = ui.content {
                plus,
                {
                    type = ui.TYPE.Text,
                    template = I.MWUI.templates.textNormal,
                    props = {text = L(capital(attributeId) .. 'Abbreviation'), textAlignH = ui.ALIGNMENT.Center, autoSize = false, size = v2(35, 16)}
                },
                {
                    type = ui.TYPE.Text,
                    template = I.MWUI.templates.textNormal,
                    props = {text = ' x ', autoSize = false, size = v2(19, 18), textAlignV = ui.ALIGNMENT.Start}
                },
                createAttributeField(value, set, argument, attributeId, v2(20, 0))
            }
        }
        return rendererLayout
    end

    I.Settings.registerRenderer(info.name .. 'Coefficients', function(value, set, argument)
        local rendererLayout = {
            type = ui.TYPE.Flex,
            props = {arrange = ui.ALIGNMENT.End},
            content = ui.content {}
        }
        local first = true
        for _, attributeId in pairs(attributesList) do
            rendererLayout.content:add(createCoefficientField(value, set, argument, attributeId, first))
            first = nil
        end
        return disable(argument.disabled, rendererLayout, true)
    end)

    I.Settings.registerRenderer(info.name .. 'SkillAttributes', function(value, set, argument)
        local rendererLayout = {
            type = ui.TYPE.Flex,
            props = {},
            content = ui.content {
                {
                    name = 'abbreviationsFlex',
                    type = ui.TYPE.Flex,
                    props = {horizontal = true},
                    content = ui.content {}
                },
                {
                    name = 'fieldsFlex',
                    type = ui.TYPE.Flex,
                    props = {horizontal = true},
                    content = ui.content {}
                }
            }
        }
        for _, attributeId in pairs(attributesList) do
            rendererLayout.content.abbreviationsFlex.content:add{
                type = ui.TYPE.Text,
                template = I.MWUI.templates.textNormal,
                props = {text = L(capital(attributeId) .. 'Abbreviation'), textAlignH = ui.ALIGNMENT.Center, autoSize = false, size = v2(48, 18)}
            }
            rendererLayout.content.fieldsFlex.content:add(createAttributeField(value, set, argument, attributeId, v2(40, 18)))
        end
        return disable(argument.disabled, rendererLayout, true)
    end)
end

return {
    eventHandlers = {
        [info.name .. 'RendererAttributes'] = receiveAttributeData
    }
}