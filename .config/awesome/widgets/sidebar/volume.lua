local wibox     = require("wibox")
local gears     = require("gears")
local awful     = require("awful")
local beautiful = require("beautiful")

local helpers   = require("helpers")
local daemon    = require("daemon/volume")

local widget = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = beautiful.margin / 2,
}

daemon:connect_signal("sink_inputs", function (_, sinks)
    widget:reset()
    for key, sink in pairs(sinks) do

        local volume_slider = wibox.widget {
            widget = wibox.widget.slider,
            handle_shape = gears.shape.circle,
            handle_cursor = "hand1",
            handle_width = 15,
            bar_shape = gears.shape.rounded_bar,
            background_color = "#00000000",
            color = beautiful.fg_normal,
            paddings = {
                top = 4,
                bottom = 4,
            },
            forced_height = 15,
            bar_height = 6,
            max_value = 100,
            value = sink.volume,
        }

        local mute_change = false
        volume_slider:connect_signal("mouse::enter", function ()
            mute_change = true
        end)
        volume_slider:connect_signal("mouse::leave", function ()
            mute_change = false
        end)

        volume_slider:connect_signal("property::value", function (_, val)
            daemon:emit_signal("volume", { key = key, value = val })
        end)

        daemon:connect_signal("sink_input_change_" .. key, function (_, data)
            if mute_change or not data then
                return
            end
            volume_slider._private.value = data.volume
            volume_slider:emit_signal("widget::redraw_needed")
        end)

        local w = wibox.widget {
            layout = wibox.layout.fixed.horizontal,
        }
        widget:add(w)
        local icon_path = helpers.misc.find_icon(sink.app_bin, sink.app_name)
        if icon_path then
            local icon = wibox.widget {
                widget = wibox.widget.imagebox,
                image = gears.surface.load_uncached(icon_path),
                resize = true,
                valign = "center",
                halign = "center",
                forced_height = 22,
                forced_width = 40,
                buttons = {
                    awful.button({}, 1, function ()
                        daemon:emit_signal("mute_toggle", key)
                        daemon:emit_signal("refresh")
                    end)
                }
            }
            if sink.muted then
                icon.opacity = 0.5
            end
            w:add(icon)
        else
            w:add(wibox.widget {
                widget = wibox.widget.textbox,
                text = sink.app_name or "None",
                forced_width = 40,
                halign = "center",
            })
        end
        w:add(wibox.widget {
            layout = wibox.layout.stack,
            fill_space = true,
            volume_slider,
        })
    end
end)

return widget
