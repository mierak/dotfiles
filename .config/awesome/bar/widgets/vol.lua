local wibox = require("wibox")
local awful = require("awful")
local theme = require("theme")
local gears = require("gears")

local helpers = require("helpers")

local vol = wibox.widget {
    widget = wibox.widget.textbox,
    font = theme.fonts.bar,
}
local mic_vol = wibox.widget {
    widget = wibox.widget.textbox,
    font = theme.fonts.bar,
}

local state = {
    volume = "",
    volume_icon = "",
    mic_volume = "",
    mic_icon = "",
}

local function set_text()
    vol.markup = helpers.misc.colorize {
        text = string.gsub(
            string.format(
                '<span font="%s">%s</span><span font="%s"> %s%%</span>',
                theme.fonts.symbols_bar,
                state.volume_icon,
                theme.fonts.bar,
                state.volume
            ),
            "\n",
            ""
        ),
        fg = theme.color4,
    }
end

local function set_mic_text()
    mic_vol.markup = helpers.misc.colorize {
        text = string.gsub(
            string.format(
                '<span font="%s">%s</span><span font="%s"> %s%%</span>',
                theme.fonts.symbols_bar,
                state.mic_icon,
                theme.fonts.bar,
                state.mic_volume
            ),
            "\n",
            ""
        ),
        fg = theme.color4,
    }
end

local function update_volume()
    awful.spawn.easy_async("volctl volume", function(str)
        state.volume = str
        set_text()
    end)
end

local function update_status()
    awful.spawn.easy_async("volctl status", function(str)
        state.volume_icon = str
        set_text()
    end)
end

local function update_mic_volume()
    awful.spawn.easy_async("volctl mic-volume", function(str)
        state.mic_volume = str
        set_mic_text()
    end)
end

local function update_mic_status()
    awful.spawn.easy_async("volctl mic-status", function(str)
        state.mic_icon = str
        set_mic_text()
    end)
end

local function update_all()
    update_volume()
    update_status()
    update_mic_volume()
    update_mic_status()
end

-- Wait for pipewire-pulse to initialize
gears.timer {
    timeout = 5,
    autostart = true,
    single_shot = true,
    callback = function()
        update_all()
    end,
}

vol:add_button(awful.button({}, 1, function(_)
    awful.spawn("volctl toggle")
end))
vol:add_button(awful.button({}, 4, function(_)
    awful.spawn("volctl inc-volume")
end))
vol:add_button(awful.button({}, 5, function(_)
    awful.spawn("volctl dec-volume")
end))

mic_vol:add_button(awful.button({}, 1, function(_)
    awful.spawn("volctl mic-toggle")
end))
mic_vol:add_button(awful.button({}, 4, function(_)
    awful.spawn("volctl mic-inc-volume")
end))
mic_vol:add_button(awful.button({}, 5, function(_)
    awful.spawn("volctl mic-dec-volume")
end))

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
