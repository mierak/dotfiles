---@diagnostic disable: lowercase-global, undefined-global
pcall(require, "luarocks.loader")

local awful = require("awful")
require("awful.autofocus")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

require("swallow") -- Has to be called before any other module initializes bling!
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title = "Oops, an error happened" .. (startup and " during startup!" or "!"),
        message = message
    }
end)

local config_dir = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

beautiful.init(config_dir .. "/awesome/theme.lua")
awful.spawn("setbg")

local create_bar_for_screen = require("bar")
local create_hotkeys = require("hotkeys")
local create_rules = require("rules")
local init_smart_borders = require("smart_borders")
local crete_tags_for_screen = require("tags")

tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
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
        awful.layout.suit.corner.nw
    })
end)


myawesomemenu = {
    {
        "hotkeys",
        function() hotkeys_popup.show_help(nil, awful.screen.focused()) end
    },
    {"manual", terminal .. " -e man awesome"},
    {"edit config", editor_cmd .. " " .. awesome.conffile},
    {"restart", awesome.restart}, {"quit", function() awesome.quit() end}
}

my_power_menu = {
    { "Shutdown", function() awful.spawn("systemctl poweroff") end },
    { "Restart", function() awful.spawn("systemctl reboot") end },
    { "Lock", function() awful.spawn.with_shell("sleep 1 && xset dpms force suspend && slock") end }
}

mymainmenu = awful.menu({
    items = {
        {"awesome", myawesomemenu, beautiful.awesome_icon},
        {"open terminal", terminal},
        { "Power", my_power_menu },
    }
})

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

screen.connect_signal("request::desktop_decoration", function(s)
    crete_tags_for_screen(s)
    create_bar_for_screen(s, mymainmenu)
end)
create_hotkeys(hotkeys_popup, menubar)
create_rules()
init_smart_borders()

if screen then
    screen[3].selected_tag.master_width_factor = 0.8
end

naughty.connect_signal("request::display",
                       function(n) naughty.layout.box {notification = n} end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:activate{context = "mouse_enter", raise = false}
end)
