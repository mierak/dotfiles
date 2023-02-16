local awful = require("awful")
local gears = require("gears")
local config = require("config")

local daemon = gears.object {}
daemon.prev = { rx = 0, tx = 0 }

function daemon:update()
    awful.spawn.easy_async_with_shell("cat /sys/class/net/[ew]*/statistics/*_bytes", function(stdout)
        local rx, tx = 0, 0
        local idx = 0
        for s in stdout:gmatch("[^\r\n]+") do
            if idx % 2 == 0 then
                rx = rx + s
            else
                tx = tx + s
            end
            idx = idx + 1
        end
        self:emit_signal("update", {
            up = (tx - self.prev.tx) / config.daemon.net_update_interval_sec,
            down = (rx - self.prev.rx) / config.daemon.net_update_interval_sec,
        })
        self.prev.rx = rx
        self.prev.tx = tx
    end)
end

local timer = gears.timer {
    autostart = true,
    timeout = config.daemon.net_update_interval_sec,
    call_now = true,
    callback = function()
        daemon:update()
    end,
}

daemon:connect_signal("stop", function()
    timer:stop()
end)

daemon:connect_signal("restart", function()
    timer:again()
end)

daemon:connect_signal("update_now", function()
    daemon:update()
end)

daemon:update()

return daemon
