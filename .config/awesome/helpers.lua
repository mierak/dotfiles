local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = {}

function helpers.colorize(args)
    return string.format("<span color=\"%s\">%s</span>", args.fg or beautiful.fg_normal, args.text)
end

function helpers.to_pill(args)
    return wibox.container.background(
        wibox.container.margin(args.widget, 10, 10),
        args.bg or beautiful.bg_alt,
        gears.shape.rounded_bar
    )
end

helpers.data_dir = os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share"
helpers.config_dir = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"

return helpers
