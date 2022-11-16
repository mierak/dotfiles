local wibox     = require("wibox")
local gears     = require("gears")
local awful     = require("awful")
local beautiful = require("beautiful")

local helpers   = require("helpers")

local button_size = 30
local thumb_size = 110

local artist = wibox.widget {
    widget = wibox.widget.textbox,
    font = beautiful.fonts.base .. "11",
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

local next = helpers.text_button {
    text         = "怜",
    align        = "right",
    fg       = beautiful.active,
    font     = beautiful.fonts.symbols_base .. button_size,
    hover    = {
        fg = beautiful.color4,
    },
    on_click     = function ()
        awesome.emit_signal("playerctl::next")
    end,
}
local prev = helpers.text_button {
    text         = "玲",
    align        = "left",
    fg       = beautiful.active,
    font     = beautiful.fonts.symbols_base .. button_size,
    hover    = {
        fg = beautiful.color4,
    },
    on_click     = function ()
        awesome.emit_signal("playerctl::previous")
    end,
}
local play_pause = helpers.text_button {
    text         = "契",
    align        = "center",
    fg       = beautiful.active,
    font     = beautiful.fonts.symbols_base .. button_size,
    hover    = {
        fg = beautiful.color4,
    },
    on_click     = function ()
        awesome.emit_signal("playerctl::play-pause")
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

awesome.connect_signal("playerctl::metadata", function (table)
    artist.markup = table.artist
    title.markup = table.title

    if table.artUrl:match("^http") then
        local filePath = "/tmp/current_thumb.jpg"
        awful.spawn.easy_async({ "curl", "-L", "-s", table.artUrl, "-o", filePath }, function ()
            art.image = gears.surface.load_uncached(filePath)
        end)
    else
        art.image = gears.surface.load_uncached(table.artUrl:gsub("file://", ""))
    end

    if table.status == "Playing" then
        play_pause.update_text("")
    else
        play_pause.update_text("契")
    end

    progress.maximum = table.length
    if not table.length or table.length > 86400 then
        timer_length.markup = "N/A"
    else
        timer_length.markup = format_seconds(table.length)
    end
end)

awesome.connect_signal("playerctl::update_position", function (table)
    progress.value = table.position
    progress.skip_next_seek = true
    if not table.position then
        timer_current.markup = "N/A"
    else
        timer_current.markup = format_seconds(table.position)
    end
end)

progress:connect_signal("property::value", function (self, value)
    if not self.skip_seek then
        awesome.emit_signal("playerctl::seek", value)
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
        art,
        {
            layout = wibox.layout.fixed.vertical,
            artist,
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
