local gears  = require("gears")
local awful  = require("awful")

local config = require("config")

local daemon = gears.object {}
daemon.last_active_time = 0
daemon.last_total_time = 0
daemon.last_usage = 0

function daemon:update()
    awful.spawn.easy_async("head -n1 /proc/stat", function (stdout)
        local idle_time = 0
        local total_time = 0
        local index = 1
        for token in stdout:gmatch("%S+") do
            if index > 1 then
                total_time = total_time + token
            end

            -- 5 is idle time and 6 is io wait time
            if index == 5 or index == 6 then
                idle_time = idle_time + token
            end
            index = index + 1
        end

        local active_time = total_time - idle_time

        local delta_active_time = active_time - self.last_active_time
        local delta_total_time = total_time - self.last_total_time
        local usage = math.ceil((delta_active_time / delta_total_time) * 100)

        self.last_active_time = active_time
        self.last_total_time = total_time
        self.last_usage = usage
        self:emit_signal("update", usage)
    end)
end

local timer = gears.timer {
    autostart = true,
    timeout   = config.daemon.cpu_update_interval_sec,
    call_now  = true,
    callback  = function ()
        daemon:update()
    end
}

daemon:connect_signal("stop", function ()
    timer:stop()
end)

daemon:connect_signal("restart", function ()
    timer:again()
end)

daemon:connect_signal("update_now", function ()
    daemon:update()
end)

return daemon
