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

return function (screen, menu)
    local tray       = wibox.widget.systray()
    local prompt_box = awful.widget.prompt { font = beautiful.fonts.bar }
    local launcher   = create_launcher(menu)
    local tag_list   = create_tag_list(screen)
    local layout_box = create_layout_box(screen)
    local task_list  = create_task_list(screen)

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
                    spacing = 10,
                    launcher,
                    tag_list,
                    prompt_box,
                },
                task_list,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = 10,
                    helpers.to_pill({ widget = fs.widget }),
                    helpers.to_pill({ widget = volume.widget }),
                    helpers.to_pill({ widget = memory.widget }),
                    helpers.to_pill({ widget = cpu.widget }),
                    helpers.to_pill({ widget = time.widget }),
                    helpers.to_pill({ widget = tray }),
                    layout_box,
                }
            },
            margins = beautiful.bar_padding,
            widget = wibox.container.margin
        }
    }
end
