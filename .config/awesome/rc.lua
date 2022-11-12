---@diagnostic disable: lowercase-global, undefined-global
pcall(require, "luarocks.loader")
local naughty = require("naughty")
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
        message = message
    }
end)

local awful = require("awful")
local beautiful = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")
local helpers = require("helpers")

require("awful.autofocus")
require("awful.hotkeys_popup.keys")
require("swallow") -- Has to be called before any other module initializes bling!

beautiful.init(helpers.config_dir .. "/awesome/theme.lua")
awful.spawn("setbg")

local create_bar_for_screen = require("bar")
local create_hotkeys = require("hotkeys")
local create_rules = require("rules")
local init_smart_borders = require("smart_borders")
local crete_tags_for_screen = require("tags")
local create_main_menu = require("main_menu")
local sidebar = require("widgets/sidebar")
require("widgets/layout_switcher")

local layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
}
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts(layouts)
end)

local main_menu = create_main_menu(hotkeys_popup)

screen.connect_signal("request::desktop_decoration", function(s)
    crete_tags_for_screen(s, layouts, awful.tag)
    create_bar_for_screen(s, main_menu)
end)
create_hotkeys(hotkeys_popup, main_menu)
create_rules()
init_smart_borders(awful, beautiful)

if screen then
    screen[3].selected_tag.master_width_factor = 0.8
end

naughty.connect_signal("request::display",
                       function(n) naughty.layout.box {notification = n} end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:activate{context = "mouse_enter", raise = false}
end)
