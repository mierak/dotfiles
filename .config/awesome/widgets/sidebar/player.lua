local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local config = require("config")

local daemon
if config.sidebar.widgets.player_backend == "mpc" then
    daemon = require("daemon.mpc")
else
    daemon = require("daemon.playerctl")
end

local helpers   = require("helpers")

local button_size = 30
local thumb_size = 110

local artist = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.fonts.base_bold .. "11",
}

local title = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.fonts.base .. "10",
}

local art = wibox.widget {
    widget = wibox.widget.imagebox,
    resize = true,
    valign = "center",
    forced_height = thumb_size,
    forced_width = thumb_size,
}
local timer_current = wibox.widget {
    widget = wibox.widget.textbox,
    halign = "left",
    font = beautiful.fonts.base .. "8",
}
local timer_length = wibox.widget {
    widget = wibox.widget.textbox,
    halign = "right",
    font = beautiful.fonts.base .. "8",
}
local timer = wibox.widget {
    layout = wibox.layout.ratio.horizontal,
    timer_current,
    timer_length,
}

local next = helpers.misc.text_button {
    text         = "󰒭",
    align        = "right",
    fg       = beautiful.active,
    font     = beautiful.fonts.symbols_base .. button_size,
    hover    = {
        fg = beautiful.color4,
    },
    on_click     = function ()
        daemon:emit_signal("next")
    end,
}
local prev = helpers.misc.text_button {
    text         = "󰒮",
    align        = "left",
    fg       = beautiful.active,
    font     = beautiful.fonts.symbols_base .. button_size,
    hover    = {
        fg = beautiful.color4,
    },
    on_click     = function ()
        daemon:emit_signal("previous")
    end,
}
local play_pause = helpers.misc.text_button {
    text         = "󰐊",
    align        = "center",
    fg       = beautiful.active,
    font     = beautiful.fonts.symbols_base .. (button_size - 8),
    hover    = {
        fg = beautiful.color4,
    },
    on_click     = function ()
        daemon:emit_signal("play-pause")
    end,
}

local progress = wibox.widget {
    widget = wibox.widget.slider,
    handle_shape = gears.shape.circle,
    handle_cursor = "hand1",
    handle_width = 15,
    bar_shape = gears.shape.rounded_bar,
    bar_height = 6,
    forced_height = 15,
    minimum = 0,
    maximum = 100,
    value = 0,
    skip_seek = true,
}
local function format_seconds(seconds)
    local minutes = math.floor(seconds / 60)
    local sec = seconds - minutes * 60
    return string.format("%d:%02d", minutes, sec)
end

daemon:connect_signal("metadata", function (_, table)
    artist.markup = table.artist
    title.markup = table.title

    art.image = gears.surface.load_uncached(table.artUrl)

    if table.status == "Playing" or table.status == "playing" then
        play_pause.update_text("")
    else
        play_pause.update_text("")
    end

    if not table.length or table.length > 86400 or table.length < 1 then
        progress.maximum = 1
        timer_length.markup = "N/A"
    else
        progress.maximum = table.length
        timer_length.markup = format_seconds(table.length)
    end
end)

daemon:connect_signal("update_position", function (_, table)
    progress.value = table.position
    progress.skip_next_seek = true
    if not table.position or table.position < 0 then
        timer_current.markup = "N/A"
    else
        timer_current.markup = format_seconds(table.position)
    end
end)

progress:connect_signal("property::value", function (self, value)
    if not self.skip_seek then
        daemon:emit_signal("seek", value)
    end
end)
progress:connect_signal("mouse::enter", function (self)
    self.skip_seek = false
end)
progress:connect_signal("mouse::leave", function (self)
    self.skip_seek = true
end)

local widget = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = beautiful.margin,
    {
        layout = wibox.layout.fixed.horizontal,
        spacing = beautiful.margin,
        {
            widget = wibox.container.background,
            bg = "#222326",
            border_width = 1,
            border_color = beautiful.active,
            art,
            forced_width = thumb_size,
            forced_height = thumb_size,
            shape = gears.shape.rounded_rect,
        },
        {
            layout = wibox.layout.fixed.vertical,
            {
                layout = wibox.container.scroll.horizontal,
                speed = 20,
                extra_space = 20,
                step_function = wibox.container.scroll.step_functions
                           .linear_increase,
                artist,
            },
            {
                layout = wibox.container.scroll.horizontal,
                speed = 20,
                extra_space = 20,
                step_function = wibox.container.scroll.step_functions
                           .linear_increase,
                title,
            },
            {
                layout = wibox.layout.ratio.horizontal,
                prev,
                play_pause,
                next,
            },
            timer,
            progress,
        },
    },
}

return widget
