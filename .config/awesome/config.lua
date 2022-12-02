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
    },
    use_confirm_dialogs = true,
    enable_tagl_preview = false,
    focus_follows_mouse = true,
    command  = {
        reboot   = "systemctl reboot",
        poweroff = "systemctl poweroff",
        lock     = "sleep 1 && xset dpms force suspend && slock",
        logout   = 'loginctl kill-user "$USER"',
    },
    weather = {
        update_interval = 1600,
    },
    redshift = {
        update_interval = 60,
    },
    playerctl = {
        players = { "mopidy" }
    },
    sidebar = {
        enabled = true,
        show_on_focused_screen = true,
        hide_on_mouse_leave = true,
    },
    bar = {
        right_widgets = {
            { "fs", "vol", "mem", "cpu", "time" }, -- Screen 1 - Middle
            { "fs", "vol", "mem", "cpu", "time" }, -- Screen 2 - Left
            { "fs", "vol", "mem", "cpu", "time" }, -- Screen 3 - Right
        },
    },
}
