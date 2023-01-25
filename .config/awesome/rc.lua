--  __  __      _  ___ ____       ___        _______ ____   ___  __  __ _____ 
-- |  \/  |_ __| |/ ( ) ___|     / \ \      / / ____/ ___| / _ \|  \/  | ____|
-- | |\/| | '__| ' /|/\___ \    / _ \ \ /\ / /|  _| \___ \| | | | |\/| |  _|  
-- | |  | | |  | . \   ___) |  / ___ \ V  V / | |___ ___) | |_| | |  | | |___ 
-- |_|  |_|_|  |_|\_\ |____/  /_/   \_\_/\_/  |_____|____/ \___/|_|  |_|_____|

pcall(require, "luarocks.loader")
local naughty = require("naughty")
local config  = require("config")
local awful         = require("awful")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.autofocus")
require("notification")

beautiful.init(config.dir.config .. "/awesome/theme.lua")

naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
        message = message
    }
end)

local create_bar_for_screen = require("bar")
local Hotkeys               = require("hotkeys")
local create_rules          = require("rules")
local crete_tags_for_screen = require("tags")
local create_main_menu      = require("main_menu")
local create_layouts        = require("layouts")

local main_menu = create_main_menu(hotkeys_popup)
local layouts = create_layouts()

Hotkeys:init(hotkeys_popup, main_menu)
create_rules()

screen.connect_signal("request::desktop_decoration", function(s)
    crete_tags_for_screen(s, layouts)
    create_bar_for_screen(s, main_menu)
end)

screen.connect_signal("request::wallpaper", function (s)
    awful.wallpaper {
        screen = s,
        widget = {
            {
                image     = beautiful.wallpaper,
                upscale   = true,
                downscale = true,
                widget    = wibox.widget.imagebox,
            },
            valign = "center",
            halign = "center",
            tiled  = false,
            widget = wibox.container.tile,
        },
    }
end)

if config.focus_follows_mouse then
    client.connect_signal("mouse::enter", function(c)
        c:activate{context = "mouse_enter", raise = false}
    end)
end

-- __        _____ ____   ____ _____ _____ ____  
-- \ \      / /_ _|  _ \ / ___| ____|_   _/ ___| 
--  \ \ /\ / / | || | | | |  _|  _|   | | \___ \ 
--   \ V  V /  | || |_| | |_| | |___  | |  ___) |
--    \_/\_/  |___|____/ \____|_____| |_| |____/ 
--                                               
if config.sidebar.enabled then
    require("widgets/sidebar")
end
if config.layout_switcher then
    require("widgets/layout_switcher")
end

--  __  __  ___  ____  _   _ _     _____ ____  
-- |  \/  |/ _ \|  _ \| | | | |   | ____/ ___| 
-- | |\/| | | | | | | | | | | |   |  _| \___ \ 
-- | |  | | |_| | |_| | |_| | |___| |___ ___) |
-- |_|  |_|\___/|____/ \___/|_____|_____|____/ 

local init_smart_borders    = require("modules.smart_borders")
local init_tags_restore     = require("modules.restore_tags")
local init_window_swallow   = require("modules.window_swallow")
local scratchpad = require("modules.scratchpad")
if config.modules.window_swallow.active then
    init_window_swallow()
end

if config.modules.restore_tags_on_restart then
    init_tags_restore()
end

if config.modules.smart_borders then
    init_smart_borders()
end

if config.modules.scratchpad.enabled then
    scratchpad:init {
        close_on_focus_lost = config.modules.scratchpad.close_on_focus_lost,
        reapply_props       = config.modules.scratchpad.reapply_props,
    }

    local commands = { "ncmpcpp-ueberzug", "" }
    for i=1,2 do
        local command
        if #commands[i] > 0 then
            command = config.terminal .. " --class scratch_term_" .. i .. " -e " .. commands[i]
        else
            command = config.terminal .. " --class scratch_term_" .. i
        end
        scratchpad:add {
                class               = "scratch_term_" .. i,
                command             = command,
                client_props = {
                    floating  = true,
                    sticky    = false,
                    geometry  = {
                        width   = 1720,
                        height  = 680,
                        x       = 100,
                        y       = 28,
                    },
                },
                hotkey        = {
                    modifiers   = { config.modkey },
                    key         = "F" .. i,
                    description = "Empty Terminal " .. i,
                    group       = "Scratchpad",
                },
            }
    end

    for i=3,4 do
        scratchpad:add_temp {
            client_props = {
                floating  = true,
                sticky    = false,
                geometry  = {
                    width   = 1720,
                    height  = 680,
                    x       = 100,
                    y       = 28,
                },
            },
            hotkey        = {
                modifiers               = { config.modkey },
                client_toggle_modifiers = { config.modkey, "Shift" },
                key                     = "F" .. i,
                description             = "Temporary Scratchpad " .. i - 2,
                group                   = "Scratchpad",
            },
        }
    end
end
