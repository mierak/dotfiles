local gears = require("gears")
local awful = require("awful")

local config = require("config")

local daemon = gears.object {}

function daemon:update()
    awful.spawn.easy_async("pgrep -x redshift", function (_, _, _, exit_code)
        if exit_code == 0 then
            awful.spawn.easy_async("redshift -p", function (stdout)
                local temp_value = stdout:match("Color temperature: (.-)\n")
                local period_value = stdout:match("Period: (.-)\n")
                daemon:emit_signal("update", temp_value, period_value)
            end)
        end
    end)
end

local timer = gears.timer {
    timeout     = config.daemon.redshift.update_interval_sec,
    call_now    = true,
    single_shot = false,
    autostart   = true,
    callback    = function ()
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
