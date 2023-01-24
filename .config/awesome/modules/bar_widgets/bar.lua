local wibox     = require("wibox")
local beautiful = require("beautiful")
local gears     = require("gears")

local helpers   = require("helpers")

local BarOnly = {}

function BarOnly:new(args)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.fg = beautiful[args.fg]
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
        font   = beautiful.fonts.bar,
        markup = helpers.misc.colorize { text = args.icon, fg = obj.fg }
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
                obj.bar,
            },
        },
    }
    obj:update(args.init_val or 0)

    return obj
end

function BarOnly:update(value)
    self.bar.value = value
end

return BarOnly
