local beautiful = require("beautiful")
local gears     = require("gears")

return function()
    local handle_border = function(c)
        local tiled_clients = c.screen.tiled_clients
        if #tiled_clients == 1 then
            for _, val in pairs(tiled_clients) do
                val.border_width = 0
            end
        else
            for _, val in pairs(tiled_clients) do
                val.border_width = beautiful.border_width
            end
        end
    end

    tag.connect_signal("tagged", handle_border)
    tag.connect_signal("untagged", handle_border)
    tag.connect_signal("request::activate", handle_border)
    client.connect_signal("property::floating", handle_border)
    -- Fix borders on startup for currently focues tags
    -- For some reason delayed_call does not work, but 0 timeout does..
    awesome.connect_signal("startup", function ()
        for s in screen do
            gears.timer {
                timeout = 0,
                autostart = true,
                single_shot = true,
                callback = function() handle_border({ screen = s }) end
            }
        end
    end)
end
