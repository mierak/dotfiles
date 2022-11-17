local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = require("helpers")

local clock = wibox.widget {
    widget = wibox.widget.textclock,
    format = helpers.colorize { text = "%H:%M:%S", fg = beautiful.fg_normal },
    refresh = 1,
    font = beautiful.fonts.bar,
}

return {
    widget = clock,
}
