local awful = require("awful")
local wibox = require("wibox")

local theme = require("theme")

local helpers = require("helpers")

return function(screen)
    return awful.widget.tasklist {
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        style = {
            font = theme.fonts.bar,
            bg_focus = theme.bg_alt,
            bg_urgent = theme.color1,
            shape = helpers.misc.rounded_rect,
            shape_border_width = theme.dpi(1),
            shape_border_color = theme.bg_alt,
        },
        layout = {
            layout = wibox.layout.flex.horizontal,
            spacing = theme.margin,
        },
        widget_template = {
            widget = wibox.container.place,
            halign = "center",
            {
                widget = wibox.container.constraint,
                width = theme.dpi(600),
                height = theme.bar_height - theme.bar_padding,
                strategy = "exact",
                {
                    id = "background_role",
                    halign = "center",
                    widget = wibox.container.background,
                    bg = theme.bg_alt,
                    {
                        widget = wibox.container.margin,
                        left = theme.margin,
                        right = theme.margin,
                        {
                            widget = wibox.container.place,
                            valign = "center",
                            halign = "center",
                            {
                                layout = wibox.layout.fixed.horizontal,
                                spacing = theme.margin,
                                {
                                    id = "clienticon",
                                    widget = awful.widget.clienticon,
                                    forced_width = theme.client_icon_size,
                                    forced_height = theme.client_icon_size,
                                },
                                {
                                    id = "text_role",
                                    widget = wibox.widget.textbox,
                                },
                            },
                        },
                    },
                },
            },
        },
        buttons = {
            awful.button({}, 3, function()
                awful.menu.client_list { theme = { width = 800 } }
            end),
            awful.button({}, 4, function()
                awful.client.focus.byidx(-1)
            end),
            awful.button({}, 5, function()
                awful.client.focus.byidx(1)
            end),
        },
    }
end
