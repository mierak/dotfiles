local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local config    = require("config")

local bling = require("bling")

local helpers = require("helpers")

local function enable_previews()
    beautiful.tag_preview_widget_border_width = 1
    beautiful.tag_preview_widget_border_color = beautiful.active
    beautiful.tag_preview_client_border_width = 0

    bling.widget.tag_preview.enable {
        show_client_content = true,
        scale = 0.25,
        honor_padding = false,
        honor_workarea = false,
        placement_fn = function(c)
            awful.placement.top_left(c, {
                margins = {
                    top = 30,
                    left = 30,
                },
                parent = awful.screen.focused(),
            })
        end,
        background_widget = wibox.widget {
            image = helpers.data_dir .. "/wallpaper/current",
            horizontal_fit_policy = "fit",
            vertical_fit_policy   = "fit",
            widget = wibox.widget.imagebox
        },
    }
end

local function get_underline_bg(selected_tags, index, widget_screen)
    local focused = false
    for _, t in pairs(selected_tags) do
        if t.index == index and t.screen.index == widget_screen.index then
            focused = true
            break
        end
    end
    if focused then
        return beautiful.fg_normal
    else
        return beautiful.bg
    end
end

return function(screen)
    if config.enable_tagl_preview then
        enable_previews()
    end
    local taglist = awful.widget.taglist {
        screen = screen,
        filter = awful.widget.taglist.filter.all,
        layout = {
            layout = wibox.layout.fixed.horizontal,
        },
        style = {
            fg_focus = beautiful.fg_normal,
            bg_focus = beautiful.bg_alt,
            fg_empty = "#6a738d",
            bg_empty = beautiful.bg_alt,
            fg_occupied = beautiful.foreground,
            bg_occupied = beautiful.bg_alt,
            font = beautiful.fonts.bar,
        },
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end)
        },
        widget_template = {
            {
                widget = wibox.container.margin,
                left = 3,
                right = 3,
                {
                    widget = wibox.layout.fixed.vertical,
                    spacing = -2,
                    {
                        widget = wibox.container.margin,
                        left = 4,
                        top = 1,
                        {
                            id     = 'text_role',
                            widget = wibox.widget.textbox,
                        },
                    },
                    {
                        {
                            widget = wibox.container.margin,
                            left = 7,
                            right = 8,
                            top = 2,
                        },
                        id = "underline",
                        bg = beautiful.fg_normal,
                        shape = gears.shape.rectangle,
                        widget = wibox.container.background,
                    }
                }
            },
            id     = 'background_role',
            widget = wibox.container.background,
            create_callback = function(self, tag, index, tags) --luacheck: no unused args
                local underline = self:get_children_by_id("underline")[1]
                underline.bg = get_underline_bg(awful.screen.focused().selected_tags, index, screen)

                self:connect_signal('mouse::enter', function()
                    if #tag:clients() > 0 then
                        awesome.emit_signal("bling::tag_preview::update", tag)
                        awesome.emit_signal("bling::tag_preview::visibility", s, true)
                    end
                end)
                self:connect_signal('mouse::leave', function()
                    awesome.emit_signal("bling::tag_preview::visibility", s, false)
                end)
            end,
            update_callback = function(self, _, index, _)
                local underline = self:get_children_by_id("underline")[1]
                underline.bg = get_underline_bg(awful.screen.focused().selected_tags, index, screen)
            end
        }
    }

    return helpers.to_pill { widget = taglist }
end
