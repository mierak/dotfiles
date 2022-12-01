local wibox     = require("wibox")
local gears     = require("gears")
local awful     = require("awful")
local beautiful = require("beautiful")

local config    = require("config")
local helpers   = require("helpers")
local daemon    = require("daemon/volume")

local widget = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = beautiful.margin / 2,
}

daemon:connect_signal("sink_inputs", function (_, sinks)
    widget:reset()
    for _, sink in ipairs(sinks) do

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
            value = math.max(sink.vol_mono or 0, sink.vol_left or 0, sink.vol_rightor or 0),
        }

        local mute_change = false
        volume_slider:connect_signal("mouse::enter", function ()
            mute_change = true
        end)
        volume_slider:connect_signal("mouse::leave", function ()
            mute_change = false
        end)

        volume_slider:connect_signal("property::value", function (_, val)
            daemon:emit_signal("volume", { index = sink.index, value = val })
        end)

        daemon:connect_signal("sink_input_change_" .. sink.index, function (_, data)
            if mute_change or not data then
                return
            end
            volume_slider._private.value = math.max(data.vol_mono or 0, data.vol_left or 0, data.vol_rightor or 0)
            volume_slider:emit_signal("widget::redraw_needed")
        end)

        local w = wibox.widget {
            layout = wibox.layout.fixed.horizontal,
        }
        widget:add(w)
        local icon_path = awful.util.geticonpath(
            sink.app_bin,
            { "png" },
            { "/usr/share/icons/hicolor/", "/usr/share/pixmaps/", config.dir.data .. "/icons", config.dir.data .. "/icons/hicolor" },
            "22"
        )
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
                        daemon:emit_signal("mute_toggle", sink.index)
                        daemon:emit_signal("refresh")
                    end)
                }
            }
            local tooltip = awful.tooltip {
                mode = "mouse",
                visible = false,
                ontop = true,
                widget = wibox.widget {
                        widget = wibox.container.background,
                        bg = "#FF0000",
                        forced_width = 400,
                        forced_height = 200,
                        ontop = true,
                        {
                            widget = wibox.widget.textbox,
                            markup = helpers.colorize { text = sink.app_name, },
                        },
                    },
            }
            icon:connect_signal("mouse::enter", function (self, result)
                print(result.y)
                tooltip.visible = true
            end)
            icon:connect_signal("mouse::leave", function ()
                tooltip.visible = false
            end)
            if sink.muted then
                icon.opacity = 0.5
            end
            w:add(icon)
        else
            w:add(wibox.widget {
                widget = wibox.widget.textbox,
                text = sink.app_bin or "None",
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
