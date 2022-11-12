local wibox     = require("wibox")
local beautiful = require("beautiful")
local awful     = require("awful")

local helpers   = require("helpers")
local cfg       = require("config")

local font = beautiful.base_font_symbols .. "32"

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
        on_click = function () awful.spawn.with_shell(cfg.command.logout) end
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
            awful.spawn(cfg.command.reboot)
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
        on_click = function () awful.spawn(cfg.command.poweroff) end
    },
}
