local gears = require("gears")
local awful = require("awful")
local config= require("config")

local daemon = gears.object {}

function daemon:update()
    awful.spawn.easy_async_with_shell("free --mebi | sed -n 2p", function (stdout)
        local index = 1
        local result = {}
        for column in stdout:gmatch("%S+") do
            if index == 2 then
                result.total = column
            elseif index == 3 then
                result.used = column
            elseif index > 3 then
                break
            end
            index = index + 1
        end
        self:emit_signal("update", result)
    end)
end

local timer = gears.timer {
    autostart = true,
    timeout = config.daemon.mem_update_interval_sec,
    call_now = true,
    callback = function ()
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
