local naughty      = require("naughty")

local notifbox     = require("notification.box")

local config       = require("config")
local notifhelpers = require("notification.helpers")

naughty.auto_reset_timeout = true

naughty.connect_signal("request::display", function (notification)
    notifbox:new(notification)
end)

naughty.connect_signal("added", function (n)
    local existing_notif = notifhelpers.find_replacable_notification(n.id, n._private.replaces_id)
    if existing_notif then
        existing_notif:emit_signal("destroyed", 4, false)
    end
    n.resident = true
    n.title = notifhelpers.modify_title(n.title)
    n.app_name = notifhelpers.modify_app_name(n)
end)

naughty.connect_signal("request::icon", function (notification, context, hints)
    if context == "clients" then
        notification.icon = notifhelpers.get_icon_for_urgency(notification.urgency)
        return
    end
    if context == "app_icon" then
        local path = notifhelpers.find_icon(notification.app_icon)
        if path then
            notification.icon = path
            return
        end
        notification.icon = notifhelpers.get_icon_for_urgency(notification.urgency)
    end
end)
