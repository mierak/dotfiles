local daemon = require("daemon.net")
local config = require("config")
local theme = require("theme")

local w = require("modules.bar_widgets")(config.bar.net)

local function byteps_to_mbps(val)
    return val / 131072
end

local function format(values)
    return string.format(
        '<span font="%s">󰃙</span><span font="%s"> %4.1fMbps </span><span font="%s">󰃘</span><span font="%s"> %4.1fMbps</span>',
        theme.fonts.symbols_bar,
        theme.fonts.bar,
        byteps_to_mbps(values.up),
        theme.fonts.symbols_bar,
        theme.fonts.bar,
        byteps_to_mbps(values.down)
    )
end

daemon:connect_signal("update", function(_, values)
    w:update(format(values))
end)

return w
