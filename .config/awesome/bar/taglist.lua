local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local helpers = require("helpers")

return function(screen)
    local taglist = awful.widget.taglist {
        screen = screen,
        filter = awful.widget.taglist.filter.all,
        layout = {
            layout = wibox.layout.fixed.horizontal, 
            spacing = 6
        },
        style = {
            fg_focus = beautiful.foreground,
            bg_focus = beautiful.bg_alt,
            fg_empty = "#6a738d",
            bg_empty = beautiful.bg_alt,
            fg_occupied = beautiful.foreground,
            bg_occupied = beautiful.bg_alt,
            font = beautiful.bar_font
        },
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end)
        }
    }

    return helpers.to_pill { widget = taglist }
end
