local wibox = require("wibox")
local awful = require("awful")

local helpers = require("helpers")
local theme = require("theme")

local create_icon = function(c)
    local icon = awful.widget.clienticon(c)
    icon.forced_width = theme.client_icon_size
    icon.forced_height = theme.client_icon_size
    return wibox.widget {
        widget = wibox.container.place,
        halign = "center",
        valign = "center",
        icon,
    }
end

local update_icons = function(self, tag)
    local icons = self:get_children_by_id("icons_role")[1]
    icons:reset()
    for _, c in ipairs(tag:clients()) do
        if not c.skip_taskbar then
            icons:add(create_icon(c))
        end
    end
end

local update_background_style = function(self, tag)
    local bg = self:get_children_by_id("bg_role")[1]
    if tag.selected then
        bg.bg = theme.bg_alt
    else
        bg.bg = theme.bg_normal
    end
    if tag.urgent then
        bg.border_color = theme.color1
        bg.bg = theme.color1
    else
        bg.border_color = theme.bg_alt
    end
end

return function(screen)
    local taglist = awful.widget.taglist {
        screen = screen,
        filter = awful.widget.taglist.filter.noempty,
        layout = {
            layout = wibox.layout.fixed.horizontal,
            spacing = theme.margin / 2,
        },
        style = {
            font = theme.fonts.bar,
        },
        buttons = {
            awful.button({}, 1, function(t)
                t:view_only()
                t:emit_signal("request::activate", t)
            end),
            awful.button({}, 4, function(t)
                awful.tag.viewprev(t.screen)
                t:emit_signal("request::activate", t)
            end),
            awful.button({}, 5, function(t)
                awful.tag.viewnext(t.screen)
                t:emit_signal("request::activate", t)
            end),
        },
        widget_template = {
            {
                widget = wibox.container.margin,
                left = theme.margin,
                right = theme.margin,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = theme.margin,
                    {
                        widget = wibox.widget.textbox,
                        id = "text_role",
                    },
                    {
                        layout = wibox.layout.fixed.horizontal,
                        spacing = theme.margin / 2,
                        id = "icons_role",
                    },
                },
            },
            id = "bg_role",
            shape = helpers.misc.rounded_rect,
            border_width = 1,
            border_color = theme.bg_alt,
            widget = wibox.container.background,
            create_callback = function(self, tag)
                update_icons(self, tag)
                update_background_style(self, tag)
            end,
            update_callback = function(self, tag)
                update_icons(self, tag)
                update_background_style(self, tag)
            end,
        },
    }
    return taglist
end
