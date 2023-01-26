local awful     = require("awful")
local gears     = require("gears")

local helpers   = require("helpers")
local config    = require("config")

local daemon = gears.object {}

local function call_api(cb)
    awful.spawn.easy_async_with_shell("openweather", function (out, _, _, exit_code)
        if exit_code ~= 0 or helpers.string.nil_or_empty(out) then
            cb()
            return
        end
        cb(out)
    end)
end

local function parse_response(response)
    local ret = {}
    ret.timestamp  = tonumber(response:match("timestamp=(.-)\n"))
    ret.icon_value = string.sub(response:match("icon=(.-)\n" or ""), 1, 3)
    ret.desc_value = response:match("desc=(.-)\n")
    ret.temp_value = string.gsub(response:match("temp=(.-)\n"), "%-0", "0")
    ret.city_value = response:match("city=(.-)\n")
    return ret
end

local function read_cached(cb)
    awful.spawn.easy_async_with_shell("cat /tmp/awm_weather", function (out, _, _, exit_code)
        if exit_code ~= 0 then
            cb()
            return
        end
        if not helpers.string.nil_or_empty(out) then
            local data = parse_response(out)
            cb(data)
        else
            cb()
        end
    end)
end

local function get_data_from_api()
    call_api(function (out)
        if not out then
            return nil
        end
        awful.spawn.with_shell('echo "' .. out .. '" > /tmp/awm_weather')
        daemon:emit_signal("update", parse_response(out))
    end)
end

function daemon:update()
    read_cached(function (data)
        awful.spawn.easy_async("date +%s", function (current_timestamp)
            if not data or data.timestamp + config.daemon.weather.update_interval_sec - 1 < tonumber(current_timestamp) then
                get_data_from_api()
            else
                daemon:emit_signal("update", data)
            end
        end)
    end)
end

local timer = gears.timer {
    timeout     = config.daemon.weather.update_interval_sec,
    call_now    = true,
    autostart   = true,
    single_shot = false,
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
    get_data_from_api()
end)

return daemon
