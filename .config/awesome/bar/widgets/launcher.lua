local awful = require("awful")

local function create(menu)
    return awful.widget.launcher({
        image = os.getenv("XDG_CONFIG_HOME") .. "/awesome/logo.png",
        menu = menu
    })
end

return create
