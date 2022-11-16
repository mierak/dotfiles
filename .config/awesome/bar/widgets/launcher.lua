local awful = require("awful")
local cfg   = require("config")

local function create(menu)
    return awful.widget.launcher({
        image = cfg.dir.assets .. "/logo.png",
        menu = menu
    })
end

return create
