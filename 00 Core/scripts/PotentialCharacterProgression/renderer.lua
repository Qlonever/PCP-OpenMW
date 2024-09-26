local I = require('openmw.interfaces')
local ui = require('openmw.ui')
local input = require('openmw.input')
local async = require('openmw.async')
local util = require('openmw.util')
local core = require('openmw.core')

local info = require('scripts.PotentialCharacterProgression.info')

if core.API_REVISION < info.minApiVersion then
    return
end

local v2 = util.vector2

I.Settings.registerRenderer(info.name .. 'KeyBind', function(value, set)
    local rendererLayout
    rendererLayout = {
        type = ui.TYPE.Container,
        template = I.MWUI.templates.box,
        content = ui.content {
            {
                type = ui.TYPE.Container,
                template = I.MWUI.templates.padding,
                content = ui.content {
                    {
                        type = ui.TYPE.Container,
                        template = I.MWUI.templates.padding,
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
        }
    }
    return rendererLayout
end)