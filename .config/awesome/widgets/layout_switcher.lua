local awful     = require("awful")
local beautiful = require("beautiful")
local wibox     = require("wibox")
local gears     = require("gears")

local cfg       = require("config")
local helpers   = require("helpers")

local size = 4

local layout_list = awful.widget.layoutlist {
    source = awful.widget.layoutlist.source.current_screen,
    style = {
        disable_icon = false,
        bg_selected  = beautiful.active,
    },
    base_layout = wibox.widget {
        spacing         = 5,
        forced_num_cols = size,
        layout          = wibox.layout.grid.vertical,
    },
    widget_template = {
        widget = wibox.container.background,
        shape  = gears.shape.rounded_rect,
        {
            id              = 'background_role',
            forced_width    = 48,
            forced_height   = 48,
            widget          = wibox.container.background,
            {
                margins = 4,
                widget  = wibox.container.margin,
                {
                    id            = 'icon_role',
                    forced_height = 46,
                    forced_width  = 46,
                    widget        = wibox.widget.imagebox,
                },
            },
        },
    },
}

local layout_popup = awful.popup {
    border_width = 0,
    placement    = awful.placement.centered,
    ontop        = true,
    visible      = false,
    shape        = gears.shape.rounded_rect,
    widget = wibox.widget {
        widget = wibox.container.background,
        bg = beautiful.bg_popup,
        {
            margins = beautiful.margin,
            widget  = wibox.container.margin,
            {
                layout = wibox.layout.fixed.vertical,
                {
                    widget = wibox.container.margin,
                    bottom = beautiful.margin,
                    {
                        widget = wibox.widget.textbox,
                        text   = "Layouts",
                        halign = "center",
                        font   = beautiful.font_title,
                    },
                },
                layout_list,
            }
        },
    },
}


awful.keygrabber {
    start_callback = function()
        layout_popup.screen  = awful.screen.focused()
        layout_list.screen   = awful.screen.focused()
        layout_popup.visible = true
    end,
    stop_callback = function()
        layout_popup.visible = false
    end,
    keypressed_callback = function(_, mod_table, key, _)
        local hasModkey = helpers.table.contains(mod_table, cfg.modkey)
        local hasShift  = helpers.table.contains(mod_table, "Shift")
        if key ~= " " then
            return
        end
        if hasModkey and hasShift then
            awful.layout.set((gears.table.cycle_value(layout_list.layouts, layout_list.current_layout, -1)))
        elseif hasModkey then
            awful.layout.set((gears.table.cycle_value(layout_list.layouts, layout_list.current_layout, 1)))
        end
    end,
    stop_event       = "release",
    stop_key         = { "Escape", "Super_L", "Super_R" },
    allowed_keys     = { cfg.modkey, " ", "shift", "h", "j", "k", "l" },
    root_keybindings = {
        awful.key {
            modifiers   = { cfg.modkey },
            key         = "space",
            group       = "Layout Switcher",
            description = "Open and Switch to Next",
            on_press    = function()
                awful.layout.set((gears.table.cycle_value(layout_list.layouts, layout_list.current_layout, 1)))
            end
        },
        awful.key {
            modifiers   = { cfg.modkey, "Shift" },
            key         = "space",
            group       = "Layout Switcher",
            description = "Open and Switch to Previous",
            on_press    = function()
                awful.layout.set((gears.table.cycle_value(layout_list.layouts, layout_list.current_layout, -1)))
            end
        },
    },
    keybindings = {
        awful.key {
            modifiers   = { cfg.modkey },
            key         = "j",
            on_press    = function()
                awful.layout.set((gears.table.cycle_value(layout_list.layouts, layout_list.current_layout, size)))
            end
        },
        awful.key {
            modifiers   = { cfg.modkey },
            key         = "k",
            on_press    = function()
                awful.layout.set((gears.table.cycle_value(layout_list.layouts, layout_list.current_layout, -size)))
            end
        },
        awful.key {
            modifiers   = { cfg.modkey },
            key         = "h",
            on_press    = function()
                awful.layout.set((gears.table.cycle_value(layout_list.layouts, layout_list.current_layout, -1)))
            end
        },
        awful.key {
            modifiers   = { cfg.modkey },
            key         = "l",
            on_press    = function()
                awful.layout.set((gears.table.cycle_value(layout_list.layouts, layout_list.current_layout, 1)))
            end
        },
    }
}
