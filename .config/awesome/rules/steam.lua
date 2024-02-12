local config = require("config")

return {
    {
        id = "steam",
        rule = {
            class = "steam"
        },
        properties = {
            screen = screen[config.screen.middle.index],
            tag = "5",
        }
    },
    {
        id = "steam-friendlist",
        rule = {
            class = "steam",
            name = "Friends List",
        },
        properties = {
            screen = screen[config.screen.right.index],
            tag = "1",
            callback = function (client)
                client:to_secondary_section()
            end,
        }
    },
    {
        id = "steam-chat",
        rule = {
            class = "steam",
        },
        except = {
            name = "Steam"
        },
        properties = {
            screen = screen[config.screen.right.index],
            tag = "1",
            callback = function (client)
                client:to_secondary_section()
            end,
        }
    },
    {
        id = "steam-news",
        rule = {
            class = "steam",
            name = "Steam %- News.*",
        },
        properties = {
            screen = screen[config.screen.middle.index],
            tag = "5",
            kill =  true,
        }
    },
}
