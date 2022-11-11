local wibox = require("wibox")
local beautiful = require("beautiful")

local lain = require("lain")
local helpers = require("helpers")

local fs = lain.widget.fs {
    widget = wibox.widget { widget = wibox.widget.textbox, font = beautiful.bar_font },
    timeout = 1800,
    notification_preset = {
        border_width = 0
    },
    settings = function ()
        widget:set_markup(helpers.colorize {
            text = string.format(" %.1f/%.1f%s", fs_now["/"].used, fs_now["/"].size, fs_now["/"].units),
            fg = beautiful.fg_normal
        })
    end
}

return {
    widget = fs.widget,
}
