local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = require("helpers")
local daemon = require("daemon.cpu")

local cpu = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.fonts.bar,
    markup = helpers.misc.colorize {
        text = string.format(" %2d%%", daemon.last_usage),
        fg = beautiful.color1
    }
}

daemon:connect_signal("update", function (_, value)
    cpu.markup = helpers.misc.colorize {
        text = string.format(" %2d%%", value),
        fg = beautiful.color1
    }
end)

return {
    widget = cpu,
}
