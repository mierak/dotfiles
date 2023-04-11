return {
    {
        id = "awakened-poe-trade",
        rule = {
            class = "awakened-poe-trade",
        },
        properties = {
            floating = true,
            focusable = false,
            ontop = false,
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
        id = "poe",
        rule = {
            class = "steam_app_238960",
        },
        properties = {
            fullscreen = false,
        },
        callback = function (c)
            require("gears.timer") {
                timeout = 1,
                autostart = true,
                single_shot = true,
                callback = function (   )
                    c:set_xproperty("_NET_WM_BYPASS_COMPOSITOR", true)
                end
            }
        end
    },
}
