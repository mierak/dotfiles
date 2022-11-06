local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local lain = require("lain")

local volume = require("bar/widgets/volume")
local create_tag_list = require("bar/taglist")
local helpers = require("helpers")

return function (screen, menu)
    local mylauncher = awful.widget.launcher({ image = os.getenv("XDG_CONFIG_HOME") .. "/awesome/logo.png",
              menu = menu })

    local fs = lain.widget.fs {
        timeout = 1800,
        settings = function ()
            widget:set_markup(helpers.colorize {
                text = string.format(" %.1f/%.1f%s", fs_now["/"].used, fs_now["/"].size, fs_now["/"].units),
                fg = beautiful.fg_normal
            })
        end
    }

    local mem = lain.widget.mem {
        timeout = 5,
        settings = function()
            widget:set_markup(helpers.colorize { 
                text = " " .. mem_now.used .. "/" .. mem_now.total .. "MiB", 
                fg = beautiful.color3
            })
        end
    }

    local cpu = lain.widget.cpu {
        timeout = 2,
        settings = function()
            widget:set_markup(helpers.colorize { 
                text = string.format(" %2d%%", cpu_now.usage),
                fg = beautiful.color1
            })
        end
    }

    local mytextclock = wibox.widget.textclock(helpers.colorize { text = "%a %d.%m.%Y %H:%M:%S", fg = beautiful.fg_normal }, 1)

    local tray = wibox.widget.systray()

    -- Create a promptbox for each screen
    screen.mypromptbox = awful.widget.prompt()

    -- Create an imagebox widget which will contain an icon indicating which layout were using.
    -- We need one layoutbox per screen.
    screen.mylayoutbox = awful.widget.layoutbox {
        screen = s,
        buttons = {
            awful.button({}, 1, function() awful.layout.inc(1) end),
            awful.button({}, 3, function() awful.layout.inc(-1) end),
            awful.button({}, 4, function() awful.layout.inc(-1) end),
            awful.button({}, 5, function() awful.layout.inc(1) end)
        }
    }

    screen.mytaglist = create_tag_list(screen)

    -- @TASKLIST_BUTTON@
    -- Create a tasklist widget
    screen.mytasklist = awful.widget.tasklist {
        screen = screen,
        filter = awful.widget.tasklist.filter.currenttags,
        buttons = {
            awful.button({}, 1, function(c)
                c:activate{context = "tasklist", action = "toggle_minimization"}
            end), awful.button({}, 3, function()
                awful.menu.client_list {theme = {width = 5}}
            end),
            awful.button({}, 4, function()
                awful.client.focus.byidx(-1)
            end),
            awful.button({}, 5, function()
                awful.client.focus.byidx(1)
            end)
        }
    }

    -- @DOC_WIBAR@
    -- Create the wibox
    screen.mywibox = awful.wibar {
        position = "top",
        screen = screen,
        height = beautiful.bar_height,
        -- @DOC_SETUP_WIDGETS@
        widget = {
            {
                layout = wibox.layout.align.horizontal,
                { -- Left widgets
                    layout = wibox.layout.fixed.horizontal,
                    spacing = 10,
                    mylauncher,
                    screen.mytaglist,
                    screen.mypromptbox
                },
                screen.mytasklist, -- Middle widget
                { -- Right widgets
                    layout = wibox.layout.fixed.horizontal,
                    spacing = 10,
                    helpers.to_pill({ widget = fs.widget }),
                    helpers.to_pill({ widget = volume.widget }),
                    helpers.to_pill({ widget = mem.widget }),
                    helpers.to_pill({ widget = cpu.widget }),
                    helpers.to_pill({ widget = mytextclock }),
                    helpers.to_pill({ widget = tray }),
                    screen.mylayoutbox
                }
            },
            margins = beautiful.bar_padding,
            widget = wibox.container.margin
        }
    }
end
