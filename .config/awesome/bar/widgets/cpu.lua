local wibox = require("wibox")
local beautiful = require("beautiful")

local lain = require("lain")
local helpers = require("helpers")

local cpu = lain.widget.cpu {
    widget = wibox.widget { widget = wibox.widget.textbox, font = beautiful.fonts.bar },
    timeout = 2,
    settings = function()
        widget:set_markup(helpers.colorize { 
            text = string.format(" %2d%%", cpu_now.usage),
            fg = beautiful.color1
        })
    end
}

return {
    widget = cpu,
}
