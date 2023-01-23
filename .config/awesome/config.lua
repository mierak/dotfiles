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
        left   = 3,
        middle = 1,
        right  = 2,
    },
    weather = {
        update_interval = 1600,
    },
    redshift = {
        update_interval = 60,
    },
    playerctl = {
        players = { "mpd" }
    },
    mpc = {
        update_interval = 2,
        enable_position_update = true,
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
        right_widgets_pill_exclude = { "status" },
        right_widgets = {
            { "status", "fs", "vol", "mem", "cpu", "time" }, -- Screen 1 - Middle
            { "fs", "vol", "mem", "cpu", "time" }, -- Screen 2 - Right
            { "fs", "vol", "mem", "cpu", "time" }, -- Screen 3 - Left
        },
    },
}
