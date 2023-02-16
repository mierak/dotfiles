local wibox = require("wibox")
local theme = require("theme")

local helpers = require("helpers")

local clock = wibox.widget {
    widget = wibox.widget.textclock,
    format = helpers.misc.colorize { text = string.format('<span font="%s">󱑁</span>', theme.fonts.symbols_bar) .. " %H:%M:%S", fg = theme.fg_normal },
    refresh = 1,
    font = theme.fonts.bar,
}

return {
    widget = clock,
}
