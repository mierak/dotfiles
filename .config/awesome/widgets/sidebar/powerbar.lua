local wibox     = require("wibox")
local beautiful = require("beautiful")
local awful     = require("awful")

local helpers   = require("helpers")
local cfg       = require("config")

local confirm  = require("widgets.confirm_dialog")

local font = beautiful.fonts.symbols_base .. "32"

return wibox.widget {
    layout              = wibox.layout.ratio.horizontal,
    inner_fill_strategy = "justify",
    helpers.text_button {
        text     = "",
        font     = font,
        align    = "center",
        fg       = beautiful.active,
        hover    = {
            fg = beautiful.color2,
        },
        on_click = function ()
            awful.spawn.with_shell(cfg.command.lock)
            awesome.emit_signal("sidebar::hide")
        end
    },
    helpers.text_button {
        text     = "",
        font     = font,
        align    = "center",
        fg       = beautiful.active,
        hover    = {
            fg = beautiful.color4,
        },
        on_click = function ()
            confirm {
                severity = "warn",
                title    = "Log Out",
                message  = "You are about to log out. Are you sure?",
                ok_text  = "Log out",
                on_click = function () awful.spawn(cfg.command.logout) end
            }
        end
    },
    helpers.text_button {
        text     = "",
        font     = font,
        align    = "center",
        fg       = beautiful.active,
        hover    = {
            fg = beautiful.color3,
        },
        on_click = function ()
            confirm {
                severity = "warn",
                title    = "Reboot PC",
                message  = "You are about to reboot this computer. Are you sure?",
                ok_text  = "Reboot",
                on_click = function () awful.spawn(cfg.command.reboot) end
            }
        end
    },
    helpers.text_button {
        text     = "⏻",
        font     = font,
        align    = "center",
        fg       = beautiful.active,
        hover    = {
            fg = beautiful.color1,
        },
        on_click = function ()
            confirm {
                severity = "warn",
                title    = "Shutdown PC",
                message  = "You are about to shutdown this computer. Are you sure?",
                ok_text  = "Shutdown",
                on_click = function () awful.spawn(cfg.command.poweroff) end
            }
        end
    },
}
