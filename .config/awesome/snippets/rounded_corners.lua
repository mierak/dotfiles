local gears = require("gears")
local beautiful = require("beautiful")
local awful = require("awful")
local corner_radius = 8

local function rounded_corners (c)
	c.shape = function (cr, w, h)
		gears.shape.rounded_rect(cr, w, h, corner_radius)
	end
end

local function square_corners (c)
	c.shape = gears.shape.rectangle
end

local function update_corners (c)     
    local screen = c.screen
    local max = screen.selected_tag == "max"
    local single_client = #screen.tiled_clients == 1
    for _, client in pairs(screen.clients) do
        if (max or single_client) and not client.floating or client.maximized then
            client.border_width = 0
            square_corners(client)
        else
            client.border_width = beautiful.border_width
            rounded_corners(client)
        end
    end
end

tag.connect_signal("tagged", update_corners)
tag.connect_signal("untagged", update_corners)