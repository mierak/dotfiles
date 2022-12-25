local ruled = require("ruled")
local awful = require("awful")
local gears = require("gears")

print(type(require("rules.misc")))

local rules = gears.table.join(
    require("rules.games"),
    require("rules.misc"),
    require("rules.steam")
)

return function()
    function awful.rules.high_priority_properties.kill(c, value, _)
        if value == true then
            c.floating = true
            c.hidden = true
            c:kill()
        end
    end

    ruled.client.connect_signal("request::rules", function()
        ruled.client.append_rules(rules)

    end)

    ruled.notification.connect_signal('request::rules', function()
        ruled.notification.append_rule {
            rule = {},
            properties = {screen = awful.screen.preferred, implicit_timeout = 5}
        }
    end)
end
