local gears         = require("gears")
local helpers       = require("helpers")

local events = {
    "client.movetotag",
    "client.movetoscreen",
    "client.focus.byidx",
    "client.focus.history.previous",
    "screen.focus",
    "menu.clients"
}

return function ()
    client.connect_signal("request::activate", function (c, context)
        if not helpers.table.contains(events, context) then
            return
        end

        gears.timer.delayed_call(function ()
            local geometry = c:geometry()
            mouse.coords({
                x = geometry.x + geometry.width / 2,
                y = geometry.y + geometry.height / 2,
            }, true)
            end)
    end)
end
