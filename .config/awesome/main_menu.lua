local awful   = require("awful")
local cfg     = require("config")

local confirm = require("widgets.confirm_dialog")

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
        { "Logout", function()
            confirm {
                severity = "warn",
                title    = "Log Out",
                message  = "You are about to log out. Are you sure?",
                ok_text  = "Log out",
                on_click = function () awful.spawn(cfg.command.logout) end
            }
        end },
        { "Restart", function()
            confirm {
                severity = "warn",
                title    = "Reboot PC",
                message  = "You are about to reboot this computer. Are you sure?",
                ok_text  = "Restart",
                on_click = function () awful.spawn(cfg.command.reboot) end
            }
        end },
        { "Shutdown", function()
            confirm {
                severity = "warn",
                title    = "Shutdown PC",
                message  = "You are about to shutdown this computer. Are you sure?",
                ok_text  = "Shutdown",
                on_click = function () awful.spawn(cfg.command.poweroff) end
            }
        end },
    }

    return awful.menu({
        items = {
            { "awesome", awesome_menu },
            { "open terminal", cfg.terminal },
            { "Power", power_menu },
        }
    })
end
