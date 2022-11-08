local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = require("helpers")

local clock = wibox.widget {
    widget = wibox.widget.textclock,
    format = helpers.colorize { text = "%a %d.%m.%Y %H:%M:%S", fg = beautiful.fg_normal },
    refresh = 1,
    font = beautiful.bar_font,
}

return {
    widget = clock,
}
