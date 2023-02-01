local awful     = require("awful")
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local helpers   = require("helpers.string")

return function(screen)
    return awful.widget.tasklist {
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        style = {
            font = beautiful.fonts.bar,
            bg_normal = beautiful.bg_alt_dark,
            bg_focus = beautiful.bg_alt,
            bg_urgent = beautiful.color1,
            shape = gears.shape.rounded_bar,
            shape_border_width = dpi(1),
            shape_border_color =  beautiful.bg_alt,
        },
        layout = {
            layout = wibox.layout.flex.horizontal,
            spacing = beautiful.margin,
        },
        widget_template = {
            widget = wibox.container.place,
            halign = "center",
            {
                widget = wibox.container.constraint,
                width = 600,
                strategy = "exact",
                {
                    id = "background_role",
                    halign = "center",
                    widget = wibox.container.background,
                    bg = beautiful.bg_alt,
                    {
                        widget = wibox.container.margin,
                        left = 10, right = 10,
                        {
                            widget = wibox.container.place,
                            halign = "center",
                            {
                                layout = wibox.layout.fixed.horizontal,
                                spacing = beautiful.margin,
                                {
                                    id = "icon_role",
                                    widget = wibox.widget.imagebox,
                                },
                                {
                                    id = "text_role",
                                    widget = wibox.widget.textbox,
                                },
                            },
                        }
                    },
                },
            },
            update_callback = function (self, _, _, _)
                local textbox = self:get_children_by_id("text_role")[1]
                textbox.text = helpers.ellipsize(textbox.text, 10)
                textbox.text = "test"
            end,
            create_callback = function (self, _, _, _)
                local textbox = self:get_children_by_id("text_role")[1]
                textbox.text = helpers.ellipsize(textbox.text, 10)
                textbox.text = "test"
            end,
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
            end)
        }
    }
end

