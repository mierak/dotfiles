local awesome = awesome
local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local gears = require("gears")
local dpi = xresources.apply_dpi
local xrdb = xresources.get_current_theme()

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()
local config = require("config")

local theme = {}
theme.dpi = dpi

local active      = awesome.xrdb_get_value("", "active")
local inactive    = awesome.xrdb_get_value("", "inactive")
local bg_alt      = awesome.xrdb_get_value("", "background-alt")
local bg_alt_dark = awesome.xrdb_get_value("", "background-alt-dark")

theme.bar_height       = dpi(28)
theme.bar_padding      = dpi(4)
theme.client_icon_size = dpi(18)

theme.wallpaper = config.dir.data .. "/wallpaper/current"

theme.fonts = {}
theme.fonts.base         = "JetBrainsMono NF "
theme.fonts.base_bold    = theme.fonts.base .. "Bold "
theme.fonts.bar          = theme.fonts.base_bold .. "9"
theme.fonts.title        = theme.fonts.base .. "13"
theme.fonts.symbols_base = "Symbols Nerd Font "
theme.fonts.symbols_bar  = theme.fonts.symbols_base .. "12"
theme.fonts.symbols      = theme.fonts.symbols_base .. "20"

theme.font          = theme.fonts.base .. "11"

theme.inactive      = inactive
theme.active        = active

theme.bg_normal     = xrdb.background
theme.bg_alt        = bg_alt
theme.bg_alt_dark   = bg_alt_dark
theme.bg_focus      = xrdb.background
theme.bg_urgent     = xrdb.color1
theme.bg_minimize   = "#444444"
theme.bg_systray    = bg_alt
theme.bg_popup      = xrdb.background

theme.fg_normal     = xrdb.foreground
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.useless_gap         = dpi(5)
theme.border_width        = dpi(4)
theme.gap_single_client   = true
theme.border_color_normal = inactive
theme.border_color_active = active
theme.border_color_marked = "#91231c"

theme.color0  = xrdb.color0
theme.color1  = xrdb.color1
theme.color2  = xrdb.color2
theme.color3  = xrdb.color3
theme.color4  = xrdb.color4
theme.color5  = xrdb.color5
theme.color6  = xrdb.color6
theme.color7  = xrdb.color7
theme.color8  = xrdb.color8
theme.color9  = xrdb.color9
theme.color10 = xrdb.color10
theme.color11 = xrdb.color11
theme.color12 = xrdb.color12
theme.color13 = xrdb.color13
theme.color14 = xrdb.color14
theme.color15 = xrdb.color15

theme.margin = dpi(10)
theme.screen_margin = dpi(5)

-- Notifications
theme.notification_position = "top_right"
theme.notification_font = theme.font
theme.notification_border_width = dpi(0)
theme.notification_border_color = active
theme.notification_shape = gears.shape.rounded_rect

theme.notification_padding = theme.screen_margin * 2
theme.notification_spacing = theme.screen_margin * 4

-- Sidebar
local sidebar = {}
theme.sidebar = sidebar

sidebar.width = dpi(400)

-- Calendar
theme.calendar_long_weekdays = true

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

theme.menu_submenu_icon = themes_path.."default/submenu.png"
theme.menu_height       = dpi(25)
theme.menu_width        = dpi(250)
theme.menu_border_width = dpi(3)
theme.menu_border_color = active
theme.menu_bg_focus     = bg_alt

-- Define the image to load
theme.titlebar_close_button_normal = themes_path.."default/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = themes_path.."default/titlebar/close_focus.png"

theme.titlebar_minimize_button_normal = themes_path.."default/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus  = themes_path.."default/titlebar/minimize_focus.png"

theme.titlebar_ontop_button_normal_inactive = themes_path.."default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themes_path.."default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themes_path.."default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = themes_path.."default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themes_path.."default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themes_path.."default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themes_path.."default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = themes_path.."default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themes_path.."default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themes_path.."default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themes_path.."default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = themes_path.."default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themes_path.."default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themes_path.."default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themes_path.."default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = themes_path.."default/titlebar/maximized_focus_active.png"


-- You can use your own layout icons like this:
theme.layout_fairh = themes_path.."default/layouts/fairhw.png"
theme.layout_fairv = themes_path.."default/layouts/fairvw.png"
theme.layout_floating  = themes_path.."default/layouts/floatingw.png"
theme.layout_magnifier = themes_path.."default/layouts/magnifierw.png"
theme.layout_max = themes_path.."default/layouts/maxw.png"
theme.layout_fullscreen = themes_path.."default/layouts/fullscreenw.png"
theme.layout_tilebottom = themes_path.."default/layouts/tilebottomw.png"
theme.layout_tileleft   = themes_path.."default/layouts/tileleftw.png"
theme.layout_tile = themes_path.."default/layouts/tilew.png"
theme.layout_tiletop = themes_path.."default/layouts/tiletopw.png"
theme.layout_spiral  = themes_path.."default/layouts/spiralw.png"
theme.layout_dwindle = themes_path.."default/layouts/dwindlew.png"
theme.layout_cornernw = themes_path.."default/layouts/cornernww.png"
theme.layout_cornerne = themes_path.."default/layouts/cornernew.png"
theme.layout_cornersw = themes_path.."default/layouts/cornersww.png"
theme.layout_cornerse = themes_path.."default/layouts/cornersew.png"

-- Generate Awesome icon:
theme.awesome_icon = theme_assets.awesome_icon(
    theme.menu_height, theme.bg_focus, theme.fg_focus
)

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
