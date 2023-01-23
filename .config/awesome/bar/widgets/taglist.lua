local wibox     = require("wibox")
local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")

local helpers   = require("helpers")

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
    local taglist = awful.widget.taglist {
        screen = screen,
        filter = awful.widget.taglist.filter.all,
        layout = {
            layout = wibox.layout.fixed.horizontal,
        },
        style = {
            fg_focus    = beautiful.fg_normal,
            bg_focus    = beautiful.bg_alt,
            fg_empty    = "#6a738d",
            bg_empty    = beautiful.bg_alt,
            fg_occupied = beautiful.foreground,
            bg_occupied = beautiful.bg_alt,
            font        = beautiful.fonts.bar,
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

    return helpers.misc.to_pill { widget = taglist }
end
