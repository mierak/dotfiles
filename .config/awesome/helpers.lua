local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local function colorize(args)
    return string.format("<span color=\"%s\">%s</span>", args.fg or beautiful.fg_normal, args.text)
end

local function to_pill(args)
    return wibox.container.background(
        wibox.container.margin(args.widget, 10, 10),
        args.bg or beautiful.bg_alt,
        gears.shape.rounded_bar
    )
end

return {
    colorize = colorize,
    to_pill = to_pill,
}