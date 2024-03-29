local gears     = require("gears")
local wibox     = require("wibox")
local awful     = require("awful")
local beautiful = require("beautiful")

local config    = require("config")

local helpers = {}

---Wraps text in pango markup
---@param args { fg: string, text: string, bg: string }
---@return string
function helpers.colorize(args)
    return string.format('<span color="%s" bgcolor="%s" bgalpha="%s">%s</span>', args.fg or beautiful.fg_normal, args.bg or "black", args.bg and "65535" or "1", args.text)
end

function helpers.to_pill(args)
    return wibox.container.background(
        wibox.container.margin(args.widget, 10, 10),
        args.bg or beautiful.bg_alt,
        gears.shape.rounded_bar
    )
end

function helpers.rounded_rect(cr, width, height)
    return gears.shape.rounded_rect(cr, width, height, 4)
end

---Places rounded rectangle background around the widget
---@param args { widget: table, bg: string? }
---@return table The widget with background as a rounded rect
function helpers.to_rounded_rect(args)
    return wibox.container.background(
        wibox.container.margin(args.widget, 10, 10),
        args.bg or beautiful.bg_alt,
        helpers.rounded_rect
    )
end

function helpers.vertical_spacer(height)
    return wibox.widget {
        forced_height = height,
        layout = wibox.layout.fixed.vertical,
    }
end

function helpers.horizontal_spacer(width)
    return wibox.widget {
        forced_width = width,
        layout = wibox.layout.fixed.horizontal,
    }
end

function helpers.add_hover_cursor(widget)
    widget:connect_signal("mouse::enter", function ()
       local w = mouse.current_wibox
       if w then
           widget.backup_cursor = w.cursor
           w.cursor = "hand1"
       end
    end)

    widget:connect_signal("mouse::leave", function ()
       local w = mouse.current_wibox
       if w then
           w.cursor = widget.backup_cursor
       end
    end)

    return widget
end

--- Creates a text button
-- @param args A table
function helpers.text_button(args)
    if not args.hover then args.hover = {} end
    if not args.margins then args.margins = {} end

    local buttons = {}
    if args.on_click then
        table.insert(buttons, awful.button({}, 1, function () args.on_click() end))
    end
    if args.on_right_click then
        table.insert(buttons, awful.button({}, 1, function () args.on_right_click() end))
    end

    local text = wibox.widget {
        markup  = helpers.colorize { text = args.text, fg = args.fg or beautiful.fg_norm },
        font    = args.font or beautiful.fonts.symbols,
        halign  = args.align,
        widget  = wibox.widget.textbox,
    }

    local button = wibox.widget {
        widget  = wibox.container.margin,
        left    = args.margins.left or 0,
        right   = args.margins.right or 0,
        top     = args.margins.top or 0,
        bottom  = args.margins.bottom or 0,
        buttons = buttons,
        text,
    }

    button:connect_signal("mouse::enter", function ()
       text.markup = helpers.colorize { text = args.text, fg = args.hover.fg or beautiful.active }
       local w = mouse.current_wibox
       if w then
           text.backup_cursor = w.cursor
           w.cursor = "hand1"
       end
    end)

    button:connect_signal("mouse::leave", function ()
       text.markup = helpers.colorize { text = args.text, fg = args.fg or beautiful.fg_norm }
       local w = mouse.current_wibox
       if w then
           w.cursor = text.backup_cursor
       end
    end)

    function button.update_text(val)
        args.text = val
        text.markup = helpers.colorize { text = val, fg = args.fg or beautiful.fg_norm }
    end

    return button
end

local icon_paths = {
    "/usr/share/icons/hicolor/",
    "/usr/share/pixmaps/",
    config.dir.assets .. "/icons/",
    config.dir.assets .. "/icons/apps/",
    config.dir.data .. "/icons/",
    config.dir.data .. "/icons/hicolor/"
}
local icon_formats = { "ico", "svg", "png", "jpg" }
function helpers.find_icon(app_binary, app_name, size)
    local icon_size = size or "22"
    return awful.util.geticonpath(app_binary, icon_formats, icon_paths, icon_size)
        or awful.util.geticonpath(app_name, icon_formats, icon_paths, icon_size)
end

return helpers
