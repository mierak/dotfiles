return {
    editor   = os.getenv("EDITOR") or "nano",
    terminal = "alacritty",
    modkey   = "Mod4",
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
    sidebar = {
        enabled = true,
        hide_on_mouse_leave = true,
    },
}
