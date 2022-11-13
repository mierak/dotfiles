local wibox = require("wibox")
local beautiful = require("beautiful")

local lain = require("lain")
local helpers = require("helpers")

local mem = lain.widget.mem {
    widget = wibox.widget { widget = wibox.widget.textbox, font = beautiful.fonts.bar },
    timeout = 5,
    settings = function()
        widget:set_markup(helpers.colorize {
            text = " " .. mem_now.used .. "/" .. mem_now.total .. "MiB",
            fg = beautiful.color3
        })
    end
}

return {
    widget = mem,
}
