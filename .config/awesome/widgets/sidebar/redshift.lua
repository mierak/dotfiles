local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")

local helpers   = require("helpers")
local cfg       = require("config")

local period = wibox.widget {
    widget = wibox.widget.textbox,
    font   = beautiful.fonts.base .. "12",
    halign = "center",
}

local icon  = wibox.widget {
    widget = wibox.widget.textbox,
    font   = beautiful.fonts.symbols_base .. "30",
    halign = "center",
}

local widget = wibox.widget {
    layout  = wibox.layout.fixed.vertical,
    spacing = beautiful.margin,
    icon,
    {
        layout = wibox.layout.align.horizontal,
        expand = "outside",
        nil,
        {
            layout = wibox.container.scroll.horizontal,
            speed = 20,
            extra_space = 20,
            step_function = wibox.container.scroll.step_functions
                       .linear_increase,
            period,
        },
    },
}

gears.timer {
    timeout     = cfg.redshift.update_interval,
    call_now    = true,
    single_shot = false,
    autostart   = true,
    callback    = function ()
        awful.spawn.easy_async("pgrep -x redshift", function (_, _, _, exit_code)
            if exit_code == 0 then
                awful.spawn.easy_async("redshift -p", function (stdout)
                    local temp_value = stdout:match("Color temperature: (.-)\n")
                    local period_value = stdout:match("Period: (.-)\n")
                    period.markup = period_value
                    if period_value == "Night" then
                        icon.markup = helpers.colorize { text = "ﯧ", fg = beautiful.color3 } .. ' <span font="' .. beautiful.fonts.base .. '21">' .. temp_value ..'</span>'
                    else
                        icon.markup = helpers.colorize { text = "", fg = beautiful.color4 } .. ' <span font="' .. beautiful.fonts.base .. '21">' .. temp_value ..'</span>'
                    end
                end)
            end
        end)
    end
}

return widget
