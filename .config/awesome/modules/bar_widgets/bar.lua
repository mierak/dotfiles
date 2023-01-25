local wibox     = require("wibox")
local beautiful = require("beautiful")
local gears     = require("gears")

local BaseBar   = require("modules.bar_widgets.bar_base")

local BarOnly = {}

function BarOnly:new(args)
    local obj = BaseBar:new(args)

    obj.widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        obj.icon,
        {
            widget = wibox.container.margin,
            top = 4, bottom = 4,
            {
                widget = wibox.container.background,
                shape = gears.shape.rounded_bar,
                bg = beautiful.active,
                obj.bar,
            },
        },
    }

    return obj
end

return BarOnly
