local config = require("config")
local awful  = require("awful")
local gears  = require("gears")

local function find_screen_config(screen)
    local screen_config
    for _, s in pairs(config.screen) do
        if s.index == screen.index then
            screen_config = s
            break
        end
    end
    return screen_config
end

return function(screen, layouts)
    local screen_config = find_screen_config(screen)
    assert(screen_config, "Screen idx: " .. screen.index .. " was not found in config. Make sure to change config.lua!")

    for i, v in ipairs(screen_config.tags) do
        local selected
        if i == 1 then selected = true else selected = false end
        local t = {
            layout = layouts[1],
            screen = screen,
            selected = selected,
        }

        if screen_config.tag_property_override and screen_config.tag_property_override[v] then
            gears.table.crush(t, screen_config.tag_property_override[v])
        end

        awful.tag.add(v, t)
    end
end
