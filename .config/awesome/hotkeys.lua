local awful           = require("awful")
local beautiful       = require("beautiful")
local key             = awful.key
local keyboard        = awful.keyboard

local bling           = require("bling")
local cfg             = require("config")
local show_gaps_popup = require("widgets/gaps_popup")

return function(hotkeys_popup, main_menu)
    local M      = { cfg.modkey }
    local M_S    = { cfg.modkey, "Shift" }
    local M_C    = { cfg.modkey, "Control" }
    local M_S_C  = { cfg.modkey, "Shift", "Control" }

    for i=1,4,1 do
    local term_scratch = bling.module.scratchpad {
        command = "alacritty --class scratch_term_" .. i,
        rule = { instance = "scratch_term_" .. i },
        sticky = true,
        autoclose = true,
        floating = true,
        geometry = { x = 100, y = 28, height = 680, width = 1720 },
        reapply = true,
        dont_focus_before_close  = false,
    }

    keyboard.append_global_keybindings({
        key {
            modifiers   = M,
            key         = "F" .. i,
            description = "Empty Terminal",
            group       = "Scratchpad",
            on_press    = function() term_scratch:toggle() end,
        },
    })
    end

    -- General Awesome keys
    keyboard.append_global_keybindings({
        key {
            modifiers   = M,
            key         = "Return",
            description = "Open a Terminal",
            group       = "Awesome",
            on_press    = function() awful.spawn(cfg.terminal) end,
        },
        key {
            modifiers   = M,
            key         = "s",
            description = "Show Help",
            group       = "Awesome",
            on_press    = hotkeys_popup.show_help,
        },
        key {
            modifiers   = M,
            key         = "w",
            description = "Show Main Menu",
            group       = "Awesome",
            on_press    = function() main_menu:show() end,
        },
        key {
            modifiers   = M,
            key         = "p",
            description = "Toggle Single Client Gaps",
            group       = "Gaps",
            on_press    = function()
                local screen = awful.screen.focused()
                if not screen then return end
                local selected_tag = screen.selected_tag
                if not selected_tag then return end

                selected_tag.gap_single_client = not selected_tag.gap_single_client
                awful.layout.arrange(screen)
                show_gaps_popup(selected_tag)
            end,
        },
        key {
            modifiers   = M,
            key         = "o",
            description = "Toggle All Gaps",
            group       = "Gaps",
            on_press    = function()
                local screen = awful.screen.focused()
                if not screen then return end
                local selected_tag = screen.selected_tag
                if not selected_tag then return end

                if selected_tag.gap == 0 then
                    selected_tag.gap = beautiful.useless_gap
                else
                    selected_tag.gap = 0
                end
                show_gaps_popup(selected_tag)
            end
        },
        key {
            modifiers   = M,
            key         = "x",
            description = "Lua Execute Prompt",
            group       = "Awesome",
            on_press    = function()
                awful.prompt.run {
                prompt = "Run Lua code: ",
                textbox = awful.screen.focused().prompt.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
                }
            end,
        },
        key {
            modifiers   = M_S,
            key         = "r",
            description = "Reload Awesome",
            group       = "Awesome",
            on_press    = awesome.restart,
        },
        key {
            modifiers   = M_S,
            key         = "q",
            description = "Quit Awesome",
            group       = "Awesome",
            on_press    = awesome.quit,
        },
    })

    if cfg.sidebar.enabled then
        keyboard.append_global_keybindings({
            key {
                modifiers   = M,
                key         = "`",
                description = "Toggle Sidebar",
                group       = "Awesome",
                on_press    = function() awesome.emit_signal("sidebar::toggle") end,
            },
        })
    end

    -- Tags related keybindings
    keyboard.append_global_keybindings({
        key {
            modifiers   = M,
            key         = "Left",
            description = "View Previous",
            group       = "Tag",
            on_press    = awful.tag.viewprev,
        },
        key {
            modifiers   = M,
            key         = "Right",
            description = "View Next",
            group       = "Tag",
            on_press    = awful.tag.viewnext,
        },
        key {
            modifiers   = M,
            key         = "Escape",
            description = "View Next",
            group       = "Tag",
            on_press    = awful.tag.history.restore,
        },
    })

    -- Movement by direction
    --[[for k, v in pairs({ { "j", "down" }, { "k", "up" }, { "h", "left" }, { "l", "right" } }) do
        keyboard.append_global_keybindings({
            key {
                modifiers   = M,
                key         = v[1],
                description = "Focus Down/Up/Left/Right",
                group       = "Client",
                on_press    = function() awful.client.focus.bydirection(v[2]) end,
            },
            key {
                modifiers   = M_S,
                key         = v[1],
                description = "Swap Down/Up/Left/Right",
                group       = "Client",
                on_press    = function() awful.client.swap.bydirection(v[2]) end,
            },
        })
    end]]--

    -- Movement by index
    for _, v in pairs({ { "j", 1 }, { "k", -1 } }) do
        keyboard.append_global_keybindings({
            key {
                modifiers   = M,
                key         = v[1],
                description = "Focus Next/Previous Client",
                group       = "Client",
                on_press    = function() awful.client.focus.byidx(v[2]) end,
            },
            key {
                modifiers   = M_S,
                key         = v[1],
                description = "Swap Client With Next/Previous Client",
                group       = "Client",
                on_press    = function() awful.client.swap.byidx(v[2]) end,
            },
        })
    end

    -- Focus related keybindings
    keyboard.append_global_keybindings({
        key {
            modifiers   = M_C,
            key         = "Tab",
            description = "Go Back",
            group       = "Client",
            on_press    = function()
                awful.client.focus.history.previous()
                if client.focus then client.focus:raise() end
            end,
        },
        key {
            modifiers   = M_C,
            key         = "j",
            description = "Focus Next Screen",
            group       = "Screen",
            on_press    = function() awful.screen.focus_relative(1) end,
        },
        key {
            modifiers   = M_C,
            key         = "k",
            description = "Focus Previous Screen",
            group       = "Screen",
            on_press    = function() awful.screen.focus_relative(-1) end,
        },
        key {
            modifiers   = M,
            key         = ",",
            description = "Focus Left Screen",
            group       = "Screen",
            on_press    = function() awful.screen.focus(screen[2]) end,
        },
        key {
            modifiers   = M,
            key         = ".",
            description = "Focus Middle Screen",
            group       = "Screen",
            on_press    = function() awful.screen.focus(screen[1]) end,
        },
        key {
            modifiers   = M,
            key         = "/",
            description = "Focus Right Screen",
            group       = "Screen",
            on_press    = function() awful.screen.focus(screen[3]) end,
        },
        key {
            modifiers   = M_C,
            key         = "n",
            description = "Restore Minimized",
            group       = "Client",
            on_press    = function()
                local c = awful.client.restore()
                if c then
                    c:activate{raise = true, context = "key.unminimize"}
                end
            end,
        },
    })

    -- Layout related keybindings
    keyboard.append_global_keybindings({
        key {
            modifiers   = M,
            key         = "u",
            description = "Jump to Urgent Client",
            group       = "Client",
            on_press    = awful.client.urgent.jumpto,
        },
        key {
            modifiers   = M_S,
            key         = "h",
            description = "Increase Number of Clients in Master",
            group       = "Layout",
            on_press    = function() awful.tag.incnmaster(1, nil, true) end,
        },
        key {
            modifiers   = M_S,
            key         = "l",
            description = "Decrease Number of Clients in Master",
            group       = "Layout",
            on_press    = function() awful.tag.incnmaster(-1, nil, true) end,
        },
        key {
            modifiers   = M_S_C,
            key         = "l",
            description = "Increase Number of Columns",
            group       = "Layout",
            on_press    = function() awful.tag.incncol(1, nil, true) end,
        },
        key {
            modifiers   = M_S_C,
            key         = "h",
            description = "Decrease Number of Columns",
            group       = "Layout",
            on_press    = function() awful.tag.incncol(-1, nil, true) end,
        },
        --[[key {
            modifiers   = M,
            key         = "space",
            description = "Next Layout",
            group       = "Layout",
            on_press    = function() awful.layout.inc(1) end,
        },
        key {
            modifiers   = M_S,
            key         = "space",
            description = "Previous Layout",
            group       = "Layout",
            on_press    = function() awful.layout.inc(-1) end,
        },]]--
        key {
            modifiers   = M,
            key         = "l",
            description = "Decrease Master Width",
            group       = "Layout",
            on_press    = function() awful.tag.incmwfact(0.05) end,
        },
        key {
            modifiers   = M,
            key         = "h",
            description = "Increase Master Width",
            group       = "Layout",
            on_press    = function() awful.tag.incmwfact(-0.05) end,
        },
    })

    keyboard.append_global_keybindings({
        key {
            modifiers   = M,
            keygroup    = "numrow",
            description = "Only View Tag",
            group       = "Tag",
            on_press    = function(index)
                local screen = awful.screen.focused()
                local tag = screen.tags[index]
                if tag then
                    tag:view_only()
                    tag:emit_signal("request::activate", tag)
                end
            end
        },
        key {
            modifiers   = M_C,
            keygroup    = "numrow",
            description = "Toggle Tag",
            group       = "Tag",
            on_press = function(index)
                local screen = awful.screen.focused()
                local tag = screen.tags[index]
                if tag then awful.tag.viewtoggle(tag) end
            end
        },
        key {
            modifiers   = M_S,
            keygroup    = "numrow",
            description = "Move Focused Client to Tag and View",
            group       = "Tag",
            on_press = function(index)
                if client.focus then
                    local tag = client.focus.screen.tags[index]
                    if tag then
                        client.focus:move_to_tag(tag)
                        tag:view_only()
                        tag:emit_signal("request::activate", tag)
                    end
                end
            end
        },
        key {
            modifiers   = M_S_C,
            keygroup    = "numrow",
            description = "Toggle Focused Client on Tag",
            group       = "Tag",
            on_press    = function(index)
                if client.focus then
                    local tag = client.focus.screen.tags[index]
                    if tag then client.focus:toggle_tag(tag) end
                end
            end
        },
        key {
            modifiers   = M,
            keygroup    = "numpad",
            description = "Select Layout Directly",
            group       = "Layout",
            on_press    = function(index)
                local t = awful.screen.focused().selected_tag
                if t then t.layout = t.layouts[index] or t.layout end
            end
        }
    })

    client.connect_signal("request::default_keybindings", function()
        keyboard.append_client_keybindings({
            key {
                modifiers   = M,
                key         = "f",
                description = "Toggle Fullscreen",
                group       = "Client",
                on_press    = function(c)
                    c.fullscreen = not c.fullscreen
                    c:raise()
                end,
            },
            key {
                modifiers   = M,
                key         = "q",
                description = "Kill Client",
                group       = "Client",
                on_press    = function(c) c:kill() end,
            },
            key {
                modifiers   = M_S,
                key         = "Return",
                description = "Move to Master",
                group       = "Client",
                on_press    = function(c) c:swap(awful.client.getmaster()) end,
            },
            key {
                modifiers   = M_S,
                key         = ".",
                description = "Move to Middle Screen",
                group       = "Client",
                on_press    = function(c) c:move_to_screen(screen[1]) end,
            },
            key {
                modifiers   = M_S,
                key         = ",",
                description = "Move to Left Screen",
                group       = "Client",
                on_press    = function(c) c:move_to_screen(screen[2]) end,
            },
            key {
                modifiers   = M_S,
                key         = "/",
                description = "Move to Right Screen",
                group       = "Client",
                on_press    = function(c) c:move_to_screen(screen[3]) end,
            },
            key {
                modifiers   = M,
                key         = "n",
                description = "Minimize",
                group       = "Client",
                on_press    = function(c)
                    c.minimized = true
                end,
            },
            key {
                modifiers   = M,
                key         = "m",
                description = "(Un)maximize",
                group       = "Client",
                on_press    = function(c)
                    c.maximized = not c.maximized
                    c:raise()
                end,
            },
            key {
                modifiers   = M_C,
                key         = "m",
                description = "(Un)maximize Vertically",
                group       = "Client",
                on_press    = function(c)
                    c.maximized_vertical = not c.maximized_vertical
                    c:raise()
                end,
            },
            key {
                modifiers   = M_S,
                key         = "m",
                description = "(Un)maximize Horizontally",
                group       = "Client",
                on_press    = function(c)
                    c.maximized_horizontal = not c.maximized_horizontal
                    c:raise()
                end,
            },
            key {
                modifiers   = M,
                key         = "t",
                description = "Toggle Floating",
                group       = "Client",
                on_press    = awful.client.floating.toggle,
            },
            key {
                modifiers   = M_C,
                key         = "space",
                description = "Toggle Keep on Top",
                group       = "Client",
                on_press    = function(c)
                    c.ontop = not c.ontop
                end,
            },
        })
    end)

    client.connect_signal("request::default_mousebindings", function()
        awful.mouse.append_client_mousebindings({
            awful.button({}, 1, function(c)
                c:activate{context = "mouse_click"}
            end),
            awful.button({ cfg.modkey }, 1, function(c)
                c.floating = true
                c:activate{context = "mouse_click", action = "mouse_move"}
            end),
            awful.button({ cfg.modkey }, 3, function(c)
                c:activate{context = "mouse_click", action = "mouse_resize"}
            end)
        })
    end)

    awful.mouse.append_global_mousebindings({
        awful.button({}, 3, function() main_menu:toggle() end),
        awful.button({}, 4, awful.tag.viewprev),
        awful.button({}, 5, awful.tag.viewnext)
    })
end
