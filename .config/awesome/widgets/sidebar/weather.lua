local awful     = require("awful")
local wibox     = require("wibox")
local beautiful = require("beautiful")

local daemon    = require("daemon.weather")
local helpers   = require("helpers")

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
    font   = beautiful.fonts.base .. "12",
    halign = "center",
}

local icon  = wibox.widget {
    widget = wibox.widget.textbox,
    font   = beautiful.fonts.symbols_base .. "30",
    halign = "center",
}


local function update_widget(data)
    icon.markup = helpers.misc.colorize { text = icons[data.icon_value].icon, fg = icons[data.icon_value].color } .. ' <span font="' .. beautiful.fonts.base .. '21">' .. data.temp_value .. '°C</span>'
    description.markup = data.city_value
end

local function set_no_data()
    icon.markup = "---"
    description.markup = "No Data"
end

icon.buttons = {
    awful.button({}, 1, function ()
        description.markup = "Updating"
        daemon:emit_signal("update_now")
    end),
}

daemon:connect_signal("update", function (_, data)
    if not data then
        set_no_data()
        return
    end
    update_widget(data)
end)

local widget = wibox.widget {
    layout  = wibox.layout.fixed.vertical,
    spacing = beautiful.margin,
    icon,
    description,
}

return widget
