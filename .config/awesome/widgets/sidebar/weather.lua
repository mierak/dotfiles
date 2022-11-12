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

local description = wibox.widget {
    widget = wibox.widget.textbox,
    font   = beautiful.base_font .. "12",
    halign = "center",
}

local icon  = wibox.widget {
    widget = wibox.widget.textbox,
    font   = beautiful.base_font_symbols .. "30",
    halign = "center",
}

local function parse(response)
    local ret = {}
    ret.timestamp  = tonumber(response:match("timestamp=(.-)\n"))
    ret.icon_value = string.sub(response:match("icon=(.-)\n"), 1, 3)
    ret.desc_value = response:match("desc=(.-)\n")
    ret.temp_value = response:match("temp=(.-)\n")
    ret.city_value = response:match("city=(.-)\n")
    return ret
end

local function read_cached(cb)
    awful.spawn.easy_async_with_shell("cat /tmp/awm_weather", function (out, _, _, exit_code)
        if exit_code ~= 0 then
            cb()
        end
        local data = parse(out)
        cb(data)
    end)
end

local function update_widget(data)
    icon.markup = helpers.colorize { text = icons[data.icon_value].icon, fg = icons[data.icon_value].color } .. " " .. data.temp_value .. "°C"
    description.markup = data.city_value
end

local function update()
    awful.spawn.easy_async_with_shell("openweather", function (out)
        awful.spawn.with_shell('echo "' .. out .. '" > /tmp/awm_weather')
        local data = parse(out)
        update_widget(data)
    end)
end

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
                        update()
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
