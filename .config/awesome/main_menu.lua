local awful = require("awful")
local cfg = require("config")

return function(hotkeys_popup)
    local awesome_menu = {
        {
            "hotkeys",
            function() hotkeys_popup.show_help(nil, awful.screen.focused()) end
        },
        { "manual", cfg.terminal .. " -e man awesome" },
        { "edit config", cfg.terminal .. " -e " .. cfg.editor .. " " .. awesome.conffile },
        { "restart", awesome.restart }, { "quit", function() awesome.quit() end },
    }

    local power_menu = {
        { "Lock", function() awful.spawn.with_shell(cfg.command.lock) end },
        { "Logout", function() awful.spawn.with_shell(cfg.command.logout) end },
        { "Restart", function() awful.spawn(cfg.command.reboot) end },
        { "Shutdown", function() awful.spawn(cfg.command.poweroff) end },
    }

    return awful.menu({
        items = {
            { "awesome", awesome_menu },
            { "open terminal", cfg.terminal },
            { "Power", power_menu },
        }
    })
end
