local gears = require("gears")

return {
    editor   = os.getenv("EDITOR") or "nano",
    terminal = "alacritty",
    modkey   = "Mod4",
    dir = {
        assets = gears.filesystem.get_configuration_dir() .. "assets",
        data   = os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share",
        config = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config",
        cache  = os.getenv("XDG_CACHE_HOME") or os.getenv("HOME") .. "/.cache",
        music  = os.getenv("HOME") .. "/Music",
    },
    modules = {
        restore_tags_on_restart = true,
        smart_borders           = true,
        focus_center_mouse      = true,
        scratchpad              = {
            enabled              = true,
            close_on_focus_lost  = true,
            reapply_props        = true,
        },
        window_swallow = {
            active = true,
            parent_filter_list_active = true,
            parent_filter_list = {
                "Vivaldi%-stable",
                "code-oss",
                "code",
                "discord",
                "firefox",
                "Microsoft Teams %- Preview",
                "krita",
                "Skype",
                "Pcmanfm",
                "Virt%-manager",
                "KeePassXC",
            },
        },
    },
    daemon = {
        cpu_update_interval_sec = 2,
        mem_update_interval_sec = 5,
        fs = {
            update_interval_sec = 1600,
            locations = { "/", "/home", "/boot" },
        },
        mpc = {
            update_interval = 2,
            enable_position_update = true,
        },
        playerctl = {
            players = { "mpd" }
        },
        redshift = {
            update_interval_sec = 60,
        },
        weather = {
            update_interval_sec = 1600,
        },
    },
    use_confirm_dialogs     = true,
    focus_follows_mouse     = true,
    command  = {
        reboot   = "systemctl reboot",
        poweroff = "systemctl poweroff",
        lock     = "sleep 1 && xset dpms force suspend && slock",
        logout   = 'loginctl kill-user "$USER"',
    },
    screen = {
        left   = {
            index = 3,
            tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
            tag_property_override = {
                ["1"] = { gap_single_client = false }
            }
        },
        middle = {
            index = 1,
            tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
            tag_property_override = {
                ["1"] = { gap_single_client = false }
            }
        },
        right  = {
            index = 2,
            tags = { "1", "2", "3", "4", "5", "6", "7", "8", "9" },
            tag_property_override = {
                ["1"] = { master_width_factor = 0.8, }
            },
        },
    },
    layout_switcher = true,
    sidebar = {
        enabled = true,
        show_on_focused_screen = true,
        hide_on_mouse_leave = true,
        widgets = {
            player_backend = "mpc", -- (mpc|playerctl)
        },
    },
    bar = {
        taglist_style = "clienticon", -- (classic|clienticon)
        right_widgets_background_exclude = { "status" },
        right_widgets = {
            { "status", "vol", "fs", "mem", "cpu", "time" }, -- Screen 1 - Middle
            { "vol", "fs", "mem", "cpu", "time" }, -- Screen 2 - Right
            { "vol", "fs", "mem", "cpu", "time" }, -- Screen 3 - Left
        },
        cpu = {
            style     = "text_bar", -- (text_bar|segment_bar|bar|text)
            fg        = "color1",
            icon      = " ",
            bar_width = 70,
        },
        mem = {
            style     = "bar", -- (text_bar|segment_bar|bar|text)
            fg        = "color3",
            icon      = " ",
            bar_width = 70,
        },
        fs = {
            style     = "bar", -- (text_bar|segment_bar|bar|text)
            fg        = "fg_normal",
            icon      = " ",
            bar_width = 70,
        },
    },
}
