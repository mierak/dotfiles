local wibox     = require("wibox")
local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")

local helpers = require("helpers")
local cfg     = require("config")

local create_launcher   = require("bar/widgets/launcher")
local create_tag_list   = require("bar/widgets/taglist")
local create_layout_box = require("bar/widgets/layouts")
local create_task_list  = require("bar/widgets/tasklist")

local create_clienticon_taglist = require("bar.widgets.clienticon_taglist")
local widgets = {}

-- Gets all widgets that appear in right_widgets config. Rest is ignored.
local function get_all_enabled_widgets()
    local result = {}
    for _, v in ipairs(cfg.bar.right_widgets) do
        for _, w in ipairs(v) do
            if not helpers.table.contains(result, w) then
                table.insert(result, w)
            end
        end
    end
    return result
end

-- Only load widgets if they appear anywhere in the bar to avoid starting their daemons needlessly
for _, v in ipairs(get_all_enabled_widgets()) do
    widgets[v] = require("bar/widgets/" .. v).widget
end

return function (screen, menu)
    local logo_menu   = create_launcher(menu)
    local tag_list
    local layout_box = create_layout_box(screen)
    local task_list  = create_task_list(screen)
    if cfg.bar.taglist_style == "classic" then
        tag_list = create_tag_list(screen)
    else
        tag_list = create_clienticon_taglist(screen)
    end

    local right_widgets = {
        layout = wibox.layout.fixed.horizontal,
        spacing = beautiful.margin,
    }
    -- Init widgets from config as defined in config for given screen
    local widgets_for_screen = cfg.bar.right_widgets[screen.index] or {}
    for i=1,#widgets_for_screen do
        if gears.table.hasitem(cfg.bar.right_widgets_pill_exclude, widgets_for_screen[i]) then
            table.insert(right_widgets, widgets[widgets_for_screen[i]])
        else
            table.insert(right_widgets, helpers.misc.to_pill { widget = widgets[widgets_for_screen[i]] })
        end
    end
    -- Append systray only on main screen
    if screen.index == 1 then
        local tray = wibox.widget.systray()
        table.insert(right_widgets, helpers.misc.to_pill { widget = tray })
    end
    -- Layoutbox on every screen
    table.insert(right_widgets, layout_box)

    screen.mywibox = awful.wibar {
        position = "top",
        screen = screen,
        height = beautiful.bar_height,
        widget = {
            {
                layout = wibox.layout.align.horizontal,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = beautiful.margin,
                    logo_menu,
                    tag_list,
                },
                {
                    widget = wibox.container.margin,
                    left = beautiful.margin, right = beautiful.margin,
                    {
                        widget = wibox.container.place,
                        halign = "center",
                        task_list,
                    },
                },
                right_widgets,
            },
            top = beautiful.bar_padding, bottom = beautiful.bar_padding,
            left = beautiful.margin, right = beautiful.margin,
            widget = wibox.container.margin
        }
    }
end
