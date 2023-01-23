local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = require("helpers")

local daemon = require("daemon.mem")

local mem = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.fonts.bar,
}

daemon:connect_signal("update", function (_, values)
    mem.markup = helpers.misc.colorize {
        text = " " .. values.used .. "/" .. values.total .. "MiB",
        fg = beautiful.color3
    }
end)

return {
    widget = mem,
}
