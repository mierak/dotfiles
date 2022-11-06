local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local helpers = require("helpers")

local vol = wibox.widget.textbox()
local mic_vol = wibox.widget.textbox()

local state = {
    volume = "",
    volume_icon = "",
    mic_volume = "",
    mic_icon = "",
}

local function set_text()
    vol.markup = helpers.colorize { 
        text = string.gsub(
            string.format("%s %s%%", state.volume_icon, state.volume),
            "\n",
            ""
        ),
        fg = beautiful.color4,
    }
end

local function set_mic_text()
    mic_vol.markup = helpers.colorize { 
        text = string.gsub(
            string.format("%s %s%%", state.mic_icon, state.mic_volume),
            "\n",
            ""
        ),
        fg = beautiful.color4,
    }
end

local function update_volume()
    awful.spawn.easy_async("volctl volume", function(str) state.volume = str set_text() end)
end

local function update_status()
    awful.spawn.easy_async("volctl status", function(str) state.volume_icon = str set_text() end)
end

local function update_mic_volume()
    awful.spawn.easy_async("volctl mic-volume", function(str) state.mic_volume = str set_mic_text() end)
end

local function update_mic_status()
    awful.spawn.easy_async("volctl mic-status", function(str) state.mic_icon = str set_mic_text() end)
end

local function update_all()
    update_volume()
    update_status()
    update_mic_volume()
    update_mic_status()
end

update_all()

vol:add_button(
    awful.button({}, 1, function(c)
        awful.spawn("volctl toggle")
    end)
)
vol:add_button(
    awful.button({}, 4, function(c)
        awful.spawn("volctl inc-volume")
    end)
)
vol:add_button(
    awful.button({}, 5, function(c)
        awful.spawn("volctl dec-volume")
    end)
)

mic_vol:add_button(
    awful.button({}, 1, function(c)
        awful.spawn("volctl mic-toggle")
    end)
)
mic_vol:add_button(
    awful.button({}, 4, function(c)
        awful.spawn("volctl mic-inc-volume")
    end)
)
mic_vol:add_button(
    awful.button({}, 5, function(c)
        awful.spawn("volctl mic-dec-volume")
    end)
)

return {
    widget = wibox.widget {
        mic_vol,
        vol,
        layout = wibox.layout.fixed.horizontal,
        spacing = 10,
    },
    update_all = update_all,
    update_volume = update_volume,
    update_status = update_status,
    update_mic_volume = update_mic_volume,
    update_mic_status = update_mic_status,
}
