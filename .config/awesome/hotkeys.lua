---@diagnostic disable: undefined-global
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local key = awful.key
local keyboard = awful.keyboard

local bling = require("bling")
local popup = require("popup")

local function show_gaps_popup(selected_tag)
    popup({ 
        title = "<span size=\"x-large\">\tGaps</span>", 
        message = "Single Client Gap:\t"
            .. (selected_tag.gap_single_client and "Enabled" or "Disabled")
            .. "\nGaps:\t\t\t"
            .. (selected_tag.gap == 0 and "Disabled" or "Enabled")
    })
end

return function(hotkeys_popup, menubar)
    local M     = { modkey }
    local M_S   = { modkey, "Shift" }
    local M_C   = { modkey, "Control" }
    local M_S_C = { modkey, "Shift", "Control" }
    
    local term_scratch = bling.module.scratchpad {
        command = "alacritty --class scratch_term_1",
        rule = { instance = "scratch_term_1" },
        sticky = true,
        autoclose = true,
        floating = true,
        geometry = { x = 100, y = 28, height = 900, width = 1720 },
        reapply = true,
        dont_focus_before_close  = false,
    }
    term_scratch:connect_signal("initial_apply", function(c) term_scratch:turn_off() end)

    -- Scratchpad hotkeys
    keyboard.append_global_keybindings({
        key {
            modifiers   = M,
            key         = "F1",
            description = "Empty Terminal",
            group       = "Scratchpad",
            on_press    = function() term_scratch:toggle() end,
        },
    })

    -- General Awesome keys
    keyboard.append_global_keybindings({
        key {
            modifiers   = M,
            key         = "Return",
            description = "Open a Terminal",
            group       = "Launcher",
            on_press    = function() awful.spawn(terminal) end,
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
            group       = "Gaps",
            on_press    = function() mymainmenu:show() end,
        },
        key {
            modifiers   = M,
            key         = "p",
            description = "Toggle Single Client Gaps",
            group       = "Awesome",
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
                textbox = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval"
                }
            end,
        },
        key {
            modifiers   = M,
            key         = "r",
            description = "Run Prompt",
            group       = "Launcher",
            on_press    = function() awful.screen.focused().mypromptbox:run() end,
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

    -- Focus related keybindings
    keyboard.append_global_keybindings({
        key {
            modifiers   = M,
            key         = "j",
            description = "Focus Next by Index",
            group       = "Client",
            on_press    = function() awful.client.focus.byidx(1) end,
        },
        key {
            modifiers   = M,
            key         = "k",
            description = "Focus Previous by Index",
            group       = "Client",
            on_press    = function() awful.client.focus.byidx(-1) end,
        },
        key {
            modifiers   = M,
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
            modifiers   = M_S,
            key         = "j",
            description = "Swap Client With Next by Index",
            group       = "Client",
            on_press    = function() awful.client.swap.byidx(1) end,
        },
        key {
            modifiers   = M_S,
            key         = "k",
            description = "Swap Client With Previous by Index",
            group       = "Client",
            on_press    = function() awful.client.swap.byidx(-1) end,
        },
        key {
            modifiers   = M,
            key         = "u",
            description = "Jump to Urgent Client",
            group       = "Client",
            on_press    = awful.client.urgent.jumpto,
        },
        key {
            modifiers   = M,
            key         = "l",
            description = "Increase Master Width Factor",
            group       = "Layout",
            on_press    = function() awful.tag.incmwfact(0.05) end,
        },
        key {
            modifiers   = M,
            key         = "h",
            description = "Decrease Master Width Factor",
            group       = "Layout",
            on_press    = function() awful.tag.incmwfact(-0.05) end,
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
            modifiers   = M_C,
            key         = "h",
            description = "Increase Number of Columns",
            group       = "Layout",
            on_press    = function() awful.tag.incncol(1, nil, true) end,
        },
        key {
            modifiers   = M_C,
            key         = "l",
            description = "Decrease Number of Columns",
            group       = "Layout",
            on_press    = function() awful.tag.incncol(-1, nil, true) end,
        },
        key {
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
            awful.button({modkey}, 1, function(c)
                c.floating = true
                c:activate{context = "mouse_click", action = "mouse_move"}
            end),
            awful.button({modkey}, 3, function(c)
                c:activate{context = "mouse_click", action = "mouse_resize"}
            end)
        })
    end)

    awful.mouse.append_global_mousebindings({
        awful.button({}, 3, function() mymainmenu:toggle() end),
        awful.button({}, 4, awful.tag.viewprev),
        awful.button({}, 5, awful.tag.viewnext)
    })
end
