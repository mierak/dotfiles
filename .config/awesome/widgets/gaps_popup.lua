local wibox     = require("wibox")
local beautiful = require("beautiful")
local gears     = require("gears")
local awful     = require("awful")

local timeout = 0.75

local function bool_to_mark(val)
    return val and " " or " "
end

local function create_row(col1)
    local name = wibox.widget {
        widget       = wibox.widget.textbox,
        forced_width = 200,
        text         = col1,
    }
    local value = wibox.widget {
        widget = wibox.widget.textbox,
    }
    local row = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        name,
        value,
    }

    return {
        widget    = row,
        set_name  = function(val) name.text = val end,
        set_value = function(val) value.text = val end,
    }
end

local row1 = create_row("Single Client Gaps:")
local row2 = create_row("Global Gaps:")
local popup = awful.popup {
    widget =  {
        widget  = wibox.container.margin,
        margins = beautiful.margin,
        {
            layout = wibox.layout.fixed.vertical,
            {
                widget = wibox.container.margin,
                bottom = beautiful.margin,
                {
                    widget = wibox.widget.textbox,
                    text   = "Gaps",
                    halign = "center",
                    font   = beautiful.fonts.title,
                },
            },
            row1.widget,
            row2.widget,
        }
    },
    placement           = awful.placement.centered,
    shape               = gears.shape.rounded_rect,
    bg                  = beautiful.bg_popup,
    ontop               = true,
    border_width        = 0,
    border_color        = beautiful.active,
    hide_on_right_click = true,
    screen              = awful.screen.focused(),
    visible             = false,
    type                = "notification",
}

local timer = gears.timer {
    timeout     = timeout,
    autostart   = true,
    single_shot = true,
    callback    = function()
        if popup.visible then
            popup.visible = false
        end
    end
}

local function show_gaps_popup(selected_tag)
    row1.set_value(bool_to_mark(selected_tag.gap_single_client))
    row2.set_value(bool_to_mark(selected_tag.gap ~= 0))
    timer:again()
    popup.screen = awful.screen.focused()
    popup.visible = true
end

return show_gaps_popup
