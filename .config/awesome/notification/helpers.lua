local naughty   = require("naughty")

local config    = require("config")
local helpers   = require("helpers")

local ret = {}

function ret.get_icon_for_urgency(severity)
    if severity == "critical" then
        return config.dir.assets .. "/icons/error.png"
    end
    return config.dir.assets .. "/icons/info.png"
end

function ret.find_replacable_notification(id, rid)
    if not rid then return nil end
    for _, v in pairs(naughty.active) do
        if v._private.replaces_id == rid and v.id ~= id then
            return v
        end
    end
    return nil
end

function ret.modify_title(title)
    if not title or #title == 0 then
        return ""
    end
    return title
end

function ret.modify_app_name(notification)
    if not notification.app_name or #notification.app_name == 0 or notification.app_name == "notify-send" or notification.app_name == "dunstify" then
        return "AwesomeWM"
    end
    local result = notification.app_name
    if notification.run then
        result = "(A) " .. result
    end
    return result
end

function ret.safe_timeout(timeout)
    if not timeout or timeout == 0 then return 0.1 end
    return timeout
end

function ret.find_icon(icon)
    if not icon or #icon == 0 then return nil end

    local i = helpers.misc.find_icon(icon, "", 64)
    if i then return i end

    if icon:sub(1, 1) == "/" then return icon end

    return nil
end

function ret.try_get_value_hint(notification)
    local hints = notification._private.freedesktop_hints
    if hints and hints.value then
        return hints.value
    end
    return nil
end

return ret
