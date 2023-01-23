local naughty      = require("naughty")
local wibox        = require("wibox")
local awful        = require("awful")
local beautiful    = require("beautiful")
local gears        = require("gears")

local dpi          = beautiful.xresources.apply_dpi

local notifhelpers = require("notification.helpers")
local helpers      = require("helpers")


local notification_box = {}

function notification_box:new(notification)
    local progressbar = nil
    local value_hint = notifhelpers.try_get_value_hint(notification)
    if value_hint then
        progressbar = self:create_progressbar(notification, value_hint)
    end

    local icon        = self:create_icon(notification)
    local titlebar    = self:create_titlebar(notification)
    local title       = self:create_title(notification)
    local message     = self:create_message(notification)
    local actions     = self:create_actions(notification)
    local close_icon  = self:create_close_icon(notification)
    local box         = self:create_box {
        notification = notification,
        icon         = icon,
        titlebar     = titlebar,
        title        = title,
        message      = message,
        actions      = actions,
        close_icon   = close_icon,
        progressbar  = progressbar,
    }

    return box
end

function notification_box:create_icon(notification)
    return wibox.widget {
        widget = wibox.container.place,
        valign = "center",
        halign = "center",
        forced_width = dpi(80),
        forced_height = dpi(80),
        {
            widget = naughty.widget.icon,
            notification = notification,
            scaling_quality = "best",
        }
    }
end
function notification_box:create_titlebar(notification)
    local w = wibox.widget {
        widget = wibox.widget.textbox,
        font   = beautiful.fonts.base_bold .. "11",
        text   = notification.app_name,
    }
    notification:connect_signal("property::app_name", function (_, value)
        w.text = value
    end)
    return w
end
function notification_box:create_title(notification)
    local w = wibox.widget {
        widget = wibox.widget.textbox,
        font   = beautiful.fonts.base_bold .. "11",
        text   = notification.title,
    }
    notification:connect_signal("property::title", function (_, value)
        w.text = value
    end)
    return w
end
function notification_box:create_message(notification)
    local w = wibox.widget {
        widget = wibox.widget.textbox,
        text   = notification.message,
        font   = beautiful.font,
    }
    notification:connect_signal("property::message", function (_, value)
        w.text = value
    end)
    return w
end
function notification_box.create_actions(_, notification)
    return wibox.widget {
        notification = notification,
        widget       = naughty.list.actions,
        base_layout  = wibox.widget {
        layout       = wibox.layout.flex.horizontal,
        spacing      = beautiful.margin,
        },
        style = {
            bg_normal          = beautiful.bg_norm,
            underline_normal   = false,
            underline_selected = false,
        },
        widget_template = {
            widget        = wibox.container.background,
            id            = "background_role",
            forced_width  = dpi(40),
            forced_height = dpi(36),
            {
                widget = wibox.widget.textbox,
                id     = "text_role",
                halign = "center",
            },
            create_callback = function (self, action, _, _)
                helpers.misc.add_hover_cursor(self)
                local bg = self:get_children_by_id("background_role")[1]
                self:connect_signal("mouse::enter", function ()
                    bg.bg = beautiful.active
                end)
                self:connect_signal("mouse::leave", function ()
                    bg.bg = beautiful.bg_norm
                end)
                self.buttons = {
                    awful.button({}, 1, function ()
                        action:invoke(notification)
                    end)
                }
            end
        },
    }
end
function notification_box.create_close_icon(_, notification)
    local close_button = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.fonts.symbols_base .. "12",
        markup = helpers.misc.colorize { fg = beautiful.color4, text = "" },
        valgin = "center",
        halign = "center",
    }

    local close_icon = wibox.widget {
        widget        = wibox.container.arcchart,
        min_value     = 0,
        max_value     = notifhelpers.safe_timeout(notification.timeout),
        value         = 0,
        forced_width  = dpi(24),
        forced_height = dpi(24),
        thickness     = dpi(4),
        rounded_edge  = true,
        start_angle   = math.pi * 1.5, -- Start at top
        close_button,
    }

    local last_value = 0
    local close_icon_timer = gears.timer {
        timeout     = 0.1,
        autostart   = true,
        call_now    = false,
        single_shot = false,
        callback    = function (self)
            last_value       = last_value + 0.1
            close_icon.value = last_value
            if last_value >= notifhelpers.safe_timeout(notification.timeout) then
                self:stop()
            end
        end
    }

    close_icon.buttons = {
        awful.button({}, 1, function ()
            notification:emit_signal("destroyed", 2, false)
        end)
    }

    close_icon:connect_signal("mouse::enter", function ()
        local w = mouse.current_wibox
        if w then
            close_icon.backup_cursor = w.cursor
            w.cursor = "hand1"
        end
        close_button.markup = helpers.misc.colorize { fg = beautiful.color1, text = "" }
        close_icon:set_color(1)
    end)

    close_icon:connect_signal("mouse::leave", function ()
        local w = mouse.current_wibox
        if w then
            w.cursor = close_icon.backup_cursor
        end
        close_button.markup = helpers.misc.colorize { fg = beautiful.color4, text = "" }
        close_icon:set_color(4)
    end)

    notification:connect_signal("reset_close_icon", function (self)
        last_value           = 0
        close_icon.value     = 0
        close_icon.max_value = notifhelpers.safe_timeout(self.timeout)
        close_icon_timer:again()
    end)

    function close_icon:set_color(color_index)
        self.colors = {{
            type  = "linear",
            from  = { 0, 0 },
            to    = { 400, 400 },
            stops = {
                { 0, beautiful["color" .. color_index] },
            }
        }}
    end
    close_icon:set_color(4)

    return close_icon
end

function notification_box:create_progressbar(notification, initial_value)
    local widget = wibox.widget {
        widget           = wibox.widget.progressbar,
        max_value        = 100,
        value            = initial_value,
        forced_height    = dpi(12),
        shape            = gears.shape.rounded_bar,
        bar_shape        = gears.shape.rounded_bar,
        color            = beautiful.color4,
        background_color = beautiful.bg_alt,
    }

    notification:connect_signal("property::hint_value", function(n)
        local hint = self:try_get_value_hint(n)
        if hint then
            widget.value = hint
        end
    end)
    return widget
end

function notification_box:create_box(args)
    local body_container = wibox.widget {
        layout = wibox.layout.fixed.vertical,
        args.title,
        args.message,
    }
    if args.progressbar then
        body_container:add(args.progressbar)
    end

    local widget = naughty.layout.box {
        notification    = args.notification,
        placement       = awful.placement.top_right,
        visible         = true,
        minimum_width   = dpi(400),
        maximum_width   = dpi(400),
        type            = "notification",
        widget_template = {
            widget       = wibox.container.background,
            bg           = beautiful.bg,
            border_color = (function ()
                if args.notification.urgency == "critical" then
                    return beautiful.color1
                end
                return beautiful.active
            end)(),
            border_width = dpi(1),
            shape        = gears.shape.rounded_rect,
            {
                layout = wibox.layout.fixed.vertical,
                {
                    widget = wibox.container.background,
                    bg     = beautiful.bg_norm,
                    {
                        widget = wibox.container.margin,
                        top    = beautiful.margin,
                        left   = beautiful.margin,
                        right  = beautiful.margin,
                        bottom = beautiful.margin / 2,
                        {
                            layout = wibox.layout.align.horizontal,
                            args.titlebar,
                            nil,
                            args.close_icon,
                        },
                    },
                },
                {
                    widget  = wibox.container.margin,
                    top     = beautiful.margin / 2,
                    left    = beautiful.margin,
                    right   = beautiful.margin,
                    bottom  = beautiful.margin,
                    {
                        layout  = wibox.layout.fixed.horizontal,
                        spacing = beautiful.margin,
                        args.icon,
                        {
                            widget = wibox.container.place,
                            valign = "center",
                            body_container,
                        },
                    },
                },
                {
                    widget = wibox.container.background,
                    bg    = beautiful.bg_norm,
                    args.actions,
                },
            },
        },
    }
    -- Dont destroy notif on click
    -- Run default action on middle click
    -- Destroy notif on right click
    widget.buttons = {
        awful.button({}, 2, function ()
            if args.notification.run then
                args.notification.run()
            end
        end),
        awful.button({}, 3, function ()
            args.notification:emit_signal("destroyed", 2, false)
        end)
    }

    return widget
end

return notification_box
