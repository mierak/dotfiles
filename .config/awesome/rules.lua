local ruled = require("ruled")
local awful = require("awful")

local rules = {
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
            screen = screen[3]
        }
    },
    {
        id = "steam",
        rule = {
            class = "Steam"
        },
        properties = {
            screen = screen[1],
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
            screen = screen[3],
            tag = "1",
            focus = nil,
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
            screen = screen[3],
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
            screen = screen[1],
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
            screen = screen[2],
            tag = "2",
        }
    },
    {
        id = "mpv-floating",
        rule = {
            instance = "mpv-float",
        },
        properties = {
            screen = screen[1],
            floating = true,
        }
    },
    {
        id = "vampire-survivors",
        rule = {
            class = "Vampire_Survivors",
        },
        properties = {
            fullscreen = true,
            maximized = true,
        }
    },
    {
        id = "dota",
        rule = {
            class = "dota2",
        },
        properties = {
            fullscreen = true,
        }
    },
    {
        id = "floating",
        rule_any = {
            instance = {"copyq", "pinentry"},
            class = {"Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv"},
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester" -- xev.
            },
            role = {
                "AlarmWindow", -- Thunderbirds calendar.
                "ConfigManager", -- Thunderbirds about:config.
                "pop-up" -- e.g. Google Chromes (detached) Developer Tools.
            }
        },
        properties = {floating = true}
    }
}

return function()
    function awful.rules.high_priority_properties.kill(c, value, props)
        if value == true then
            c.floating = true
            c.hidden = true
            c:kill()
        end
    end

    ruled.client.connect_signal("request::rules", function()
        ruled.client.append_rules(rules)

    end)

    ruled.notification.connect_signal('request::rules', function()
        -- All notifications will match this rule.
        ruled.notification.append_rule {
            rule = {},
            properties = {screen = awful.screen.preferred, implicit_timeout = 5}
        }
    end)
end
