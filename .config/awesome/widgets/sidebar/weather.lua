local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local helpers   = require("helpers")
local cfg       = require("config")

local icons = {
    -- Day
    ["01d"] = { icon = "", color = beautiful.color3 },
    ["02d"] = { icon = "", color = beautiful.color4 },
    ["03d"] = { icon = "", color = beautiful.color4 },
    ["04d"] = { icon = "", color = beautiful.color4 },
    ["09d"] = { icon = "", color = beautiful.color4 },
    ["10d"] = { icon = "", color = beautiful.color4 },
    ["11d"] = { icon = "", color = beautiful.color4 },
    ["13d"] = { icon = "", color = beautiful.color4 },
    ["50d"] = { icon = "", color = beautiful.color4 },
    -- Night
    ["01n"] = { icon = "", color = beautiful.color4 },
    ["02n"] = { icon = "", color = beautiful.color4 },
    ["03n"] = { icon = "", color = beautiful.color4 },
    ["04n"] = { icon = "", color = beautiful.color4 },
    ["09n"] = { icon = "", color = beautiful.color4 },
    ["10n"] = { icon = "", color = beautiful.color4 },
    ["11n"] = { icon = "", color = beautiful.color4 },
    ["13n"] = { icon = "", color = beautiful.color4 },
    ["50n"] = { icon = "", color = beautiful.color4 },
}

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

local description = wibox.widget {
    widget = wibox.widget.textbox,
    font   = beautiful.fonts.base .. "12",
    halign = "center",
}

local icon  = wibox.widget {
    widget = wibox.widget.textbox,
    font   = beautiful.fonts.symbols_base .. "30",
    halign = "center",
}

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

local function update_widget(data)
    icon.markup = helpers.misc.colorize { text = icons[data.icon_value].icon, fg = icons[data.icon_value].color } .. ' <span font="' .. beautiful.fonts.base .. '21">' .. data.temp_value .. '°C</span>'
    description.markup = data.city_value
end

local function set_no_data()
    icon.markup = "---"
    description.markup = "No Data"
end

local function call_api_and_update_widget()
    call_api(function (out)
        if not out then
            set_no_data()
            return
        end
        awful.spawn.with_shell('echo "' .. out .. '" > /tmp/awm_weather')
        local data = parse_response(out)
        update_widget(data)
    end)
end

icon.buttons = {
    awful.button({}, 1, function ()
        description.markup = "Updating"
        call_api_and_update_widget()
    end),
}

if cfg.weather.update_interval > 0 then
    gears.timer {
        timeout     = cfg.weather.update_interval,
        call_now    = true,
        autostart   = true,
        single_shot = false,
        callback    = function ()
            read_cached(function (data)
                awful.spawn.easy_async("date +%s", function (current_timestamp)
                    if not data or data.timestamp + cfg.weather.update_interval - 1 < tonumber(current_timestamp) then
                        call_api_and_update_widget()
                    else
                        update_widget(data)
                    end
                end)
            end)
        end
    }
end


local widget = wibox.widget {
    layout  = wibox.layout.fixed.vertical,
    spacing = beautiful.margin,
    icon,
    description,
}

return widget
