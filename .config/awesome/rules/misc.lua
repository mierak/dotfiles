local awful = require("awful")
local gears = require("gears")

local config = require("config")

return {
    {
        id = "global",
        rule = {},
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap +
                awful.placement.no_offscreen,
            size_hints_honor = false
        }
    },
    {
        id = "discord",
        rule = {
            class = "discord"
        },
        properties = {
            screen = screen[config.screen.right.index],
            tag    = "1",
        }
    },
    -- { -- A very hacky rule. Wait for two seconds after firefox starts and then check WM_NAME and move to left monitor if applicable.
    --     id = "firefox-wait-name-change",
    --     rule = {
    --         class = "firefox",
    --     },
    --     callback = function (client)
    --         gears.timer {
    --             timeout = 3,
    --             single_shot = true,
    --             autostart = true,
    --             call_now = false,
    --             callback = function ()
    --                 if client and client.name:match("%Left Mon.*") then
    --                     client.screen = screen[config.screen.left.index]
    --                     client:tags({ screen[config.screen.left.index].tags[1] })
    --                 else
    --                     client.screen = screen[config.screen.middle.index]
    --                     client:tags({ screen[config.screen.middle.index].tags[1] })
    --                 end
    --             end
    --         }
    --     end
    -- },
    {
        id = "teams",
        rule = {
            class = "Microsoft Teams %- Preview",
        },
        properties = {
            screen = screen[config.screen.left.index],
            tag = "2",
        }
    },
    {
        id = "mpv-floating",
        rule = {
            instance = "mpv-float",
        },
        properties = {
            screen = screen[config.screen.middle.index],
            floating = true,
            ontop = true,
        }
    },
    {
        id = "keepass",
        rule = {
            class = "KeePassXC"
        },
        properties = {
            screen = screen[config.screen.middle.index],
            tag    = "9",
        }
    },
    {
        id = "keepass-generate-prompt",
        rule = {
            class = "KeePassXC",
            name = "Generate Password",
        },
        properties = {
            placement = awful.placement.centered,
        }
    },
    {
        id = "keepass-favicons-dialog",
        rule = {
            class = "KeePassXC",
            name = "Download Favicons",
        },
        properties = {
            placement = awful.placement.centered,
            floating = true,
        }
    },
    {
        id = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class = { "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv", "Lxpolkit" },
            name = {
                "Event Tester" -- xev.
            },
            role = {
                "pop-up" -- e.g. Google Chromes (detached) Developer Tools.
            }
        },
        properties = {
            ontop = true,
            floating = true
        }
    },
}
