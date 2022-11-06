local naughty = require("naughty")

local notif = nil
local destroyed = false

return function(args)
    if not notif or destroyed then
        notif = naughty.notification {
            title = args.title,
            text = args.message,
            position = "top_middle",
            timeout = 1,
            auto_reset_timeout = true
        }
        destroyed = false
        notif:connect_signal("destroyed", function() destroyed = true end)
    else
        notif.title = args.title
        notif.message = args.message
    end
end
