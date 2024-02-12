local wibox     = require("wibox")
local beautiful = require("beautiful")

local helpers   = require("helpers")
local BaseBar   = require("modules.bar_widgets.bar_base")

---@class TextBar : BarBase
---@field text string
local TextBar = BaseBar:new()

---@param args { fg: string, bar_width: integer, icon: string, init_val: string | integer }?
---@return TextBar
function TextBar:new(args)
    local obj = BaseBar:new(args) --[[@as TextBar]]
    setmetatable(obj, self)
    self.__index = self

    obj.text = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.fonts.base_bold .. "8",
        valign = "center",
        halign = "center",
    }

    obj.widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        obj.icon,
        {
            widget = wibox.container.margin,
            top = 4, bottom = 4,
            {
                widget = wibox.container.background,
                shape = helpers.misc.rounded_rect,
                bg = beautiful.active,
                {
                    layout = wibox.layout.stack,
                    obj.bar,
                    {
                        widget = wibox.container.background,
                        shape = require("gears.shape").partially_rounded_rect,
                        obj.text,
                    }
                },
            },
        },
    }

    return obj
end

---Updates the widget's bar value
---@param value integer Percentage value, 0-100
function TextBar:update(value)
    BaseBar.update(self, value)
    self.text.markup = helpers.misc.colorize {
        text = string.format("%2d%%", value),
        fg = self.fg
    }
end

return TextBar
