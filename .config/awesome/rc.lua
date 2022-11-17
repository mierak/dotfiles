pcall(require, "luarocks.loader")
local naughty = require("naughty")
local config  = require("config")

naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
        message = message
    }
end)

local awful         = require("awful")
local beautiful     = require("beautiful")
local hotkeys_popup = require("awful.hotkeys_popup")

require("awful.autofocus")
require("awful.hotkeys_popup.keys")
require("swallow") -- Has to be called before any other module initializes bling!

beautiful.init(config.dir.config .. "/awesome/theme.lua")
awful.spawn("setbg")

local create_bar_for_screen = require("bar")
local create_hotkeys        = require("hotkeys")
local create_rules          = require("rules")
local init_smart_borders    = require("smart_borders")
local crete_tags_for_screen = require("tags")
local create_main_menu      = require("main_menu")
local create_layouts        = require("layouts")
if config.sidebar.enabled then
    require("widgets/sidebar")
end
require("widgets/layout_switcher")


local main_menu = create_main_menu(hotkeys_popup)
local layouts = create_layouts()

create_hotkeys(hotkeys_popup, main_menu)
create_rules()
init_smart_borders(awful, beautiful)
screen.connect_signal("request::desktop_decoration", function(s)
    crete_tags_for_screen(s, layouts, awful.tag)
    create_bar_for_screen(s, main_menu)
end)

if screen and screen[3] then
    screen[3].selected_tag.master_width_factor = 0.8
end

naughty.connect_signal("request::display", function(n) naughty.layout.box { notification = n } end)

if config.focus_follows_mouse then
    client.connect_signal("mouse::enter", function(c)
        c:activate{context = "mouse_enter", raise = false}
    end)
end
