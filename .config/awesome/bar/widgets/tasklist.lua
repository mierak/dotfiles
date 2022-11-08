local awful = require("awful")
local beautiful = require("beautiful")

return function(screen)
    return awful.widget.tasklist {
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        style = {
            font = beautiful.bar_font,
        },
        buttons = {
            awful.button({}, 1, function(c)
                c:activate{ context = "tasklist", action = "toggle_minimization" }
            end), awful.button({}, 3, function()
                awful.menu.client_list { theme = { width = 5 } }
            end),
            awful.button({}, 4, function()
                awful.client.focus.byidx(-1)
            end),
            awful.button({}, 5, function()
                awful.client.focus.byidx(1)
            end)
        }
    }
end

