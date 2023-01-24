local wibox     = require("wibox")
local beautiful = require("beautiful")
local gears     = require("gears")

local helpers   = require("helpers")

local TextBar = {}

function TextBar:new(args)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.fg = beautiful[args.fg]
    obj.icon = args.icon
    obj.bar = wibox.widget {
        widget = wibox.widget.progressbar,
        shape = gears.shape.rounded_bar,
        max_value = 100,
        min_value = 0,
        margins = 1,
        value = 0,
        forced_width = args.bar_width,
        background_color = beautiful.bg_alt,
        color = obj.fg,
        border_color = beautiful.active,
    }

    obj.icon = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.fonts.bar,
        markup = helpers.misc.colorize { text = args.icon, fg = obj.fg }
    }

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
    obj:update(args.init_val or 0)

    return obj
end

function TextBar:update(value)
    self.bar.value = value
    self.text.markup = helpers.misc.colorize {
        text = string.format("%2d%%", value),
        fg = self.fg
    }
end

return TextBar
