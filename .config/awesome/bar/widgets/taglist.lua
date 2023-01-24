local wibox     = require("wibox")
local awful     = require("awful")
local beautiful = require("beautiful")

local helpers   = require("helpers")

local function update_tag_icon(self, tag)
    local tagicon = self:get_children_by_id('icon_role')[1]
    local is_screen_focused = awful.screen.focused() == tag.screen
    local fg
    if tag.urgent then
        fg = beautiful.color1
    elseif tag.selected and is_screen_focused then
        fg = beautiful.fg_normal
    else
        fg = "#6a738d"
    end

    if tag.selected then
        tagicon.text = ""
    elseif #tag:clients() == 0 then
        tagicon.text = ""
    else
        tagicon.text = ""
    end
    self.fg = fg
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
            fg_empty    = beautiful.active,
            bg_empty    = beautiful.bg_alt,
            fg_occupied = beautiful.foreground,
            bg_occupied = beautiful.bg_alt,
            bg_urgent   = beautiful.bg_alt,
            font        = beautiful.fonts.bar,
        },
        buttons = {
            awful.button({}, 1, function(t) t:view_only() end),
            awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end)
        },
        widget_template = {
            {
                widget = wibox.container.constraint,
                forced_width = 24,
                {
                    id     = 'icon_role',
                    font   = beautiful.fonts.symbols_base .. "13",
                    widget = wibox.widget.textbox,
                    halign = "center",
                    valign = "center"
                }
            },
            id     = 'background_role',
            widget = wibox.container.background,
            create_callback = function(self, tag, _, _)
                update_tag_icon(self, tag)
            end,
            update_callback = function(self, tag, _, _)
                update_tag_icon(self, tag)
            end
        }
    }

    return helpers.misc.to_pill { widget = taglist }
end
