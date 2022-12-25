local awful = require("awful")

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
            screen = screen[config.screen.right]
        }
    },
    {
        id = "steam",
        rule = {
            class = "Steam"
        },
        properties = {
            screen = screen[config.screen.middle],
            tag = "5",
        }
    },
    {
        id = "steam-friendlist",
        rule = {
            class = "Steam",
            name = "Friends List",
        },
        properties = {
            screen = screen[config.screen.right],
            tag = "1",
            callback = function (client)
                client:to_secondary_section()
            end,
        }
    },
    {
        id = "steam-chat",
        rule = {
            class = "Steam",
        },
        except = {
            name = "Steam"
        },
        properties = {
            screen = screen[config.screen.right],
            tag = "1",
            callback = function (client)
                client:to_secondary_section()
            end,
        }
    },
    {
        id = "steam-news",
        rule = {
            class = "Steam",
            name = "Steam %- News.*",
        },
        properties = {
            screen = screen[config.screen.middle],
            tag = "5",
            kill =  true,
        }
    },
    {
        id = "teams",
        rule = {
            class = "Microsoft Teams %- Preview",
        },
        properties = {
            screen = screen[config.screen.left],
            tag = "2",
        }
    },
    {
        id = "mpv-floating",
        rule = {
            instance = "mpv-float",
        },
        properties = {
            screen = screen[config.screen.middle],
            floating = true,
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
            floating = true
        }
    },
}
