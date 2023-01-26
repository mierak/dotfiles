local wibox     = require("wibox")
local beautiful = require("beautiful")

local daemon    = require("daemon.redshift")
local helpers   = require("helpers")

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

daemon:connect_signal("update", function (_, temp_value, period_value)
    period.markup = period_value
    if period_value == "Night" then
        icon.markup = helpers.misc.colorize { text = "ﯧ", fg = beautiful.color3 } .. ' <span font="' .. beautiful.fonts.base .. '21">' .. temp_value ..'</span>'
    else
        icon.markup = helpers.misc.colorize { text = "", fg = beautiful.color4 } .. ' <span font="' .. beautiful.fonts.base .. '21">' .. temp_value ..'</span>'
    end
end)

return widget
