local wibox     = require("wibox")
local naughty   = require("naughty")
local beautiful = require("beautiful")

local helpers = require("helpers")
local daemon  = require("daemon.fs")
local config  = require("config")

local fs = wibox.widget {
    widget = wibox.widget.textbox,
    font   = beautiful.fonts.bar,
}

function fs:show()
    fs.notification = naughty.notification {
        timeout = 0,
        text    = self:to_notification_text(),
        title   = "Disk Statistics",
        icon    = config.dir.assets .. "/icons/disk.png",
    }
end

function fs:hide()
    if not fs.notification then
        return
    end

    fs.notification:destroy()
    fs.notification = nil
end

function fs:to_notification_text()
    local text = ""
    for path, values in pairs(fs.stats) do
        local vals = values:toGiB()
        text = text .. "\n" .. string.format("%s\t%6.2f\t%6.2f\t%6.2f GiB", path ,vals.used, vals.available, vals.size)
    end
    return text
end

fs:connect_signal("mouse::enter", function ()
    daemon:emit_signal("update_now")
    fs:hide()
    fs:show()
end)

fs:connect_signal("mouse::leave", function ()
    fs:hide()
end)

daemon:connect_signal("update", function (_, values)
    fs.stats = values
    local stats = values["/home"]:toGiB()
    fs.markup = helpers.misc.colorize {
        text = string.format(" %.0f/%.0f GiB", stats.used, stats.size),
        fg   = beautiful.fg_normal
    }
    if fs.notification then
        fs.notification.text = fs:to_notification_text()
    end
end)

return {
    widget = fs,
}
