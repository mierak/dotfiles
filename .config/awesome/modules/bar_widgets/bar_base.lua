local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local helpers   = require("helpers")

local BarBase = {}
function BarBase:new(args)
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

    obj:update(args.init_val or 0)

    return obj
end

function BarBase:update(value)
    self.bar.value = value
end

return BarBase
