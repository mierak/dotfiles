local naughty   = require("naughty")

local daemon  = require("daemon.fs")
local config  = require("config")

local fs = require("modules.bar_widgets." .. config.bar.fs.style):new(config.bar.fs)

function fs:show()
    self.notification = naughty.notification {
        timeout = 0,
        text    = self:to_notification_text(),
        title   = "Disk Statistics",
        icon    = config.dir.assets .. "/icons/disk.png",
    }
end

function fs:hide()
    if not self.notification then
        return
    end

    self.notification:destroy()
    self.notification = nil
end

function fs:to_notification_text()
    local text = ""
    for path, values in pairs(self.stats) do
        local vals = values:toGiB()
        text = text .. "\n" .. string.format("%s\t%6.2f\t%6.2f\t%6.2f GiB", path ,vals.used, vals.available, vals.size)
    end
    return text
end

fs.widget:connect_signal("mouse::enter", function ()
    daemon:emit_signal("update_now")
    fs:hide()
    fs:show()
end)

fs.widget:connect_signal("mouse::leave", function ()
    fs:hide()
end)

daemon:connect_signal("update", function (_, values)
    fs.stats = values
    local stats = values["/home"]:toGiB()
    fs:update(stats.used / stats.size * 100, function () return string.format(config.bar.fs.icon .. "%.0f/%.0f GiB", stats.used, stats.size) end)
    if fs.notification then
        fs.notification.text = fs:to_notification_text()
    end
end)

return fs
