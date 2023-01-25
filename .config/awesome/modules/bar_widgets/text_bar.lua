local wibox     = require("wibox")
local beautiful = require("beautiful")
local gears     = require("gears")

local helpers   = require("helpers")
local BaseBar   = require("modules.bar_widgets.bar_base")

local TextBar = {}

function TextBar:new(args)
    local obj = BaseBar:new(args)
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
                shape = gears.shape.rounded_bar,
                bg = beautiful.active,
                {
                    layout = wibox.layout.stack,
                    obj.bar,
                    obj.text,
                },
            },
        },
    }

    return obj
end

function TextBar:update(value)
    BaseBar.update(self, value)
    self.text.markup = helpers.misc.colorize {
        text = string.format("%2d%%", value),
        fg = self.fg
    }
end

return TextBar
