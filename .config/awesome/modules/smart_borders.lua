local beautiful = require("beautiful")

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
    client.connect_signal("property::floating", function (client)
        if client.first_tag then
            client.first_tag:emit_signal("request::activate")
        end
    end)
end
