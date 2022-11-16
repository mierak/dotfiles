local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local create_launcher = require("bar/widgets/launcher")
local volume = require("bar/widgets/volume")
local memory = require("bar/widgets/memory")
local cpu = require("bar/widgets/cpu")
local time = require("bar/widgets/time")
local fs = require("bar/widgets/fs")
local create_tag_list = require("bar/widgets/taglist")
local create_layout_box = require("bar/widgets/layouts")
local create_task_list = require("bar/widgets/tasklist")
local helpers = require("helpers")
local cfg = require("config")

local widgets = {}
widgets.cpu  = cpu.widget
widgets.mem  = memory.widget
widgets.fs   = fs.widget
widgets.time = time.widget
widgets.vol  = volume.widget

return function (screen, menu)
    local prompt_box = awful.widget.prompt { font = beautiful.fonts.bar }
    local logo_menu   = create_launcher(menu)
    local tag_list   = create_tag_list(screen)
    local layout_box = create_layout_box(screen)
    local task_list  = create_task_list(screen)

    local right_widgets = {
        layout = wibox.layout.fixed.horizontal,
        spacing = beautiful.margin,
    }
    -- Init widgets from config as defined in config for given screen
    local widgets_for_screen = cfg.bar.right_widgets[screen.index] or {}
    for i=1,#widgets_for_screen do
        table.insert(right_widgets, helpers.to_pill { widget = widgets[widgets_for_screen[i]] })
    end
    -- Append systray only on main screen
    if screen.index == 1 then
        local tray = wibox.widget.systray()
        table.insert(right_widgets, helpers.to_pill { widget = tray })
    end
    -- Layoutbox on every screen
    table.insert(right_widgets, layout_box)

    screen.prompt = prompt_box
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
                    prompt_box,
                },
                task_list,
                right_widgets,
            },
            margins = beautiful.bar_padding,
            widget = wibox.container.margin
        }
    }
end
