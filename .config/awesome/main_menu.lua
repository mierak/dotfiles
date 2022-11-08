local awful = require("awful")
local beautiful = require("beautiful")
local cfg = require("config")

return function()
    awesome_menu = {
        {
            "hotkeys",
            function() hotkeys_popup.show_help(nil, awful.screen.focused()) end
        },
        { "manual", cfg.terminal .. " -e man awesome" },
        { "edit config", cfg.terminal .. " -e " .. cfg.editor .. " " .. awesome.conffile },
        { "restart", awesome.restart }, { "quit", function() awesome.quit() end }
    }

    power_menu = {
        { "Shutdown", function() awful.spawn("systemctl poweroff") end },
        { "Restart", function() awful.spawn("systemctl reboot") end },
        { "Lock", function() awful.spawn.with_shell("sleep 1 && xset dpms force suspend && slock") end }
    }

    return awful.menu({
        items = {
            { "awesome", awesome_menu },
            { "open terminal", cfg.terminal },
            { "Power", power_menu },
        }
    })
end
