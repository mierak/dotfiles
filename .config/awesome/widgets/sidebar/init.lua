local wibox      = require("wibox")
local beautiful  = require("beautiful")
local awful      = require("awful")
local gears      = require("gears")

local create_cal = require("widgets/sidebar/calendar")
local powerbar   = require("widgets/sidebar/powerbar")
local weather    = require("widgets/sidebar/weather")
local helpers    = require("helpers")
local cfg        = require("config")

local calendar = create_cal {
    width = beautiful.sidebar.width - 50,
}
assert(calendar, "Could not create calendar in sidebar")

local clock = wibox.widget {
    widget  = wibox.widget.textclock,
    format  = "%H:%M:%S",
    refresh = 1,
    font    = beautiful.base_font .. "44",
    halign  = "center",
}

local sidebar = wibox {
    visible = false,
    ontop   = true,
    type    = "dropdown_menu",
    screen  = screen.primary,
    width   = beautiful.sidebar.width or 300,
    height  = screen.primary.geometry.height - beautiful.bar_height * 2,
    shape   = function(cr, width, height)
        gears.shape.partially_rounded_rect(cr, width, height, false, true, false, false, 30)
    end
}
awful.placement.bottom_left(sidebar)

sidebar:setup {
    layout = wibox.container.margin,
    top = 20,
    bottom = 20,
    left = beautiful.margin,
    right = beautiful.margin,
    {
        layout = wibox.layout.fixed.vertical,
        fill_space = true,
        clock,
        helpers.vertical_spacer(20),
        {
            layout = wibox.container.place,
            halign = "center",
            calendar.calendar,
        },
        {
            layout = wibox.container.place,
            halign = "center",
            weather,
        },
        {
            layout = wibox.container.place,
            valign = "bottom",
            content_fill_horizontal = true,
            powerbar,
        },
    },
}

if cfg.sidebar.hide_on_mouse_leave then
    sidebar:connect_signal("mouse::leave", function()
        sidebar.visible = false
        calendar.reset()
    end)
end

awesome.connect_signal("sidebar::hide", function ()
    sidebar.visible = false
    calendar.reset()
end)

awesome.connect_signal("sidebar::show", function ()
    sidebar.visible = true
    calendar.reset()
end)

awesome.connect_signal("sidebar::toggle", function ()
    if sidebar.visible then
        calendar.reset()
    end
    sidebar.visible = not sidebar.visible
end)
