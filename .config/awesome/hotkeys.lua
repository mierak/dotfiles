local awful = require("awful")
local beautiful = require("beautiful")

local cfg = require("config")
local show_gaps_popup = require("widgets/gaps_popup")
local Ezhk = require("modules.ezhk")
local helpers = require("helpers")

local ezhk = Ezhk:new(cfg.modkey)

local Hotkeys = {}
--stylua: ignore
---@param hotkeys_popup HotkeysPopup
---@param main_menu any
function Hotkeys:init(hotkeys_popup, main_menu)
    ezhk:global_keybind_group("Awesome", {
        -- { "M-S-q",        "Quit Awesome",                          awesome.quit },
        { "M-S-r",        "Restart Awesome",                       awesome.restart },
        { "M-Return",     "Open a Terminal",                       Hotkeys.spawn(cfg.terminal) },
        -- { "M-s",          "Show Help",                             function() hotkeys_popup:toggle() end, hotkeys_popup ~= nil },
        --{ "M-w",          "Show Main Menu",                        function() main_menu:show() end },
        { "M-Tab",          "Toggle Sidebar",                        function() awesome.emit_signal("sidebar::toggle") end,     cfg.sidebar.enabled },
        { "M-g",          "Open rofi",                             Hotkeys.spawn('rofi -show combi -modes "combi,drun,run,window,calc" -combi-modes "window,drun,run"') },
        { "M-S-s",        "Screenshot",                            Hotkeys.spawn("screenshot") },
        --{ "M-S-c",        "Edit configs",                          Hotkeys.spawn("confedit") },
        { "M-S-p",        "Power Menu",                            Hotkeys.spawn("powermenu") },
        { "A-S-c",        "Color Picker",                          Hotkeys.colorpicker },
    })

    ezhk:client_keybind_group("Volume", {
        { "XF86AudioRaiseVolume",        "Volume Up",                      Hotkeys.spawn("volctl inc-volume") },
        { "XF86AudioLowerVolume",        "Volume Down",                    Hotkeys.spawn("volctl dec-volume") },
        { "XF86AudioMute",               "(Un)mute",                       Hotkeys.spawn("volctl toggle") },
        { "C-F11",                       "Mic Volume Up",                  Hotkeys.spawn("volctl mic-inc-volume") },
        { "C-F10",                       "Mic Volume Down",                Hotkeys.spawn("volctl mic-dec-volume") },
        { "C-F9",                        "Mic (Un)mute",                   Hotkeys.spawn("volctl mic-toggle") },
    })

    ezhk:global_keybind_group("Tag", {
        -- { "M-Left",       "View Previous",                         awful.tag.viewprev },
        -- { "M-Right",      "View Next",                             awful.tag.viewnext },
        { "M-Escape",     "View Last",                             awful.tag.history.restore },
        { "M-numrow",     "Only View Tag",                         self.only_view_tag },
        { "M-C-numrow",   "Toggle Tag",                            self.toggle_tag },
        { "M-S-numrow",   "Move Focused Client to Tag and View",   self.move_client_and_view },
        { "M-S-C-numrow", "Toggle Focused Client on Tag",          self.toggle_on_tag },
    })

    ezhk:global_keybind_group("Layout", {
        -- { "M-S-l",        "Inc/Dec Number of Clients in Master",   function() awful.tag.incnmaster(1, nil, true) end },
        -- { "M-S-h",        "Inc/Dec Number of Clients in Master",   function() awful.tag.incnmaster(-1, nil, true) end },
        -- { "M-S-C-l",      "Inc/Dec Number of Columns",             function() awful.tag.incncol(1, nil, true) end },
        -- { "M-S-C-h",      "Inc/Dec Number of Columns",             function() awful.tag.incncol(-1, nil, true) end },
        { "M-l",          "Inc/Dec Master Width",                  function() awful.tag.incmwfact(0.05) end },
        { "M-h",          "Inc/Dec Master Width",                  function() awful.tag.incmwfact(-0.05) end },
        { "M-numpad",     "Select Layout Directly",                self.select_layout_by_idx }
    })

   ezhk:global_keybind_group("Gaps", {
        { "M-p",          "Toggle Single Client Gaps",             self.toggle_single_client_gaps },
        { "M-o",          "Toggle All Gaps",                       self.toggle_all_gaps },
    })

    ezhk:global_keybind_group("Screen", {
        -- { "M-,",          "Focus Left Screen",                     function() awful.screen.focus(cfg.screen.left.index) end,   not not cfg.screen.left},
        -- { "M-.",          "Focus Middle Screen",                   function() awful.screen.focus(cfg.screen.middle.index) end, not not cfg.screen.middle },
        -- { "M-/",          "Focus Right Screen",                    function() awful.screen.focus(cfg.screen.right.index) end,  not not cfg.screen.right },
        -- { "M-x",          "Focus Left Screen",                     function() awful.screen.focus(cfg.screen.left.index) end,   not not cfg.screen.left},
        -- { "M-c",          "Focus Middle Screen",                   function() awful.screen.focus(cfg.screen.middle.index) end, not not cfg.screen.middle },
        -- { "M-d",          "Focus Right Screen",                    function() awful.screen.focus(cfg.screen.right.index) end,  not not cfg.screen.right },
        { "M-h",          "Focus Left Screen",                     function() awful.screen.focus(cfg.screen.left.index) end,   not not cfg.screen.left},
        { "M-,",          "Focus Middle Screen",                   function() awful.screen.focus(cfg.screen.middle.index) end, not not cfg.screen.middle },
        { "M-.",          "Focus Right Screen",                    function() awful.screen.focus(cfg.screen.right.index) end,  not not cfg.screen.right },
        { "M-C-j",        "Focus Next/Previous Screen",            function() awful.screen.focus_relative(1) end },
        { "M-C-k",        "Focus Next/Previous Screen",            function() awful.screen.focus_relative(-1) end },
    })

    ezhk:global_keybind_group("Client", {
        { "M-u",          "Jump to Urgent Client",                 awful.client.urgent.jumpto },
        { "M-C-Tab",      "Jump to Previous Client on Screen",     self.jump_to_previous_client },
        --{ "M-C-n",        "Restore Minimized",                     self.restore_minimized },
        { "M-j",          "Focus Next/Previous Client",            function() awful.client.focus.byidx(1) end },
        { "M-k",          "Focus Next/Previous Client",            function() awful.client.focus.byidx(-1) end },
        { "M-S-j",        "Swap Client With Next/Previous Client", function() awful.client.swap.byidx(1) end },
        { "M-S-k",        "Swap Client With Next/Previous Client", function() awful.client.swap.byidx(-1) end },
    })

    ezhk:client_keybind_group("Client", {
        { "M-f",          "Toggle Fullscreen",                     function(c) c.fullscreen = not c.fullscreen; c:raise() end },
        { "M-q",          "Kill Client",                           function(c) c:kill() end },
        { "M-S-Return",   "Move to Master",                        function(c) c:swap(awful.client.getmaster()) end },
        { "M-t",          "Toggle Floating",                       awful.client.floating.toggle },
        -- { "M-n",          "Minimize Client",                       function(c) c.minimized = true end },
        { "M-m",          "(Un)maximize",                          self.un_maximize },                                                               -- Remove? I use fullscreen instead anyway
        -- { "M-C-m",        "(Un)maximize Vertically",               function(c) c.maximized_vertical = not c.maximized_vertical; c:raise() end },     -- Remove? I use fullscreen instead anyway
        -- { "M-S-m",        "(Un)maximize Horizontally",             function(c) c.maximized_horizontal = not c.maximized_horizontal; c:raise() end }, -- Remove? I use fullscreen instead anyway
        -- { "M-C-space",    "Toggle Keep on Top",                    function(c) c.ontop = not c.ontop end },
    })

    ezhk:client_keybind_group("Client > Screen", {
        -- { "M-S-,",        "Move to Left Screen",                   function(c) c:move_to_screen(cfg.screen.left.index) end,   not not cfg.screen.left },
        -- { "M-S-.",        "Move to Middle Screen",                 function(c) c:move_to_screen(cfg.screen.middle.index) end, not not cfg.screen.middle },
        -- { "M-S-/",        "Move to Right Screen",                  function(c) c:move_to_screen(cfg.screen.right.index) end,  not not cfg.screen.right },
        -- { "M-S-x",        "Move to Left Screen",                   function(c) c:move_to_screen(cfg.screen.left.index) end,   not not cfg.screen.left },
        -- { "M-S-c",        "Move to Middle Screen",                 function(c) c:move_to_screen(cfg.screen.middle.index) end, not not cfg.screen.middle },
        -- { "M-S-d",        "Move to Right Screen",                  function(c) c:move_to_screen(cfg.screen.right.index) end,  not not cfg.screen.right },
        { "M-S-h",        "Move to Left Screen",                   function(c) c:move_to_screen(cfg.screen.left.index) end,   not not cfg.screen.left },
        { "M-S-,",        "Move to Middle Screen",                 function(c) c:move_to_screen(cfg.screen.middle.index) end, not not cfg.screen.middle },
        { "M-S-.",        "Move to Right Screen",                  function(c) c:move_to_screen(cfg.screen.right.index) end,  not not cfg.screen.right },
    })

    ezhk:global_keybind_group("Run or Raise", {
        { "M-e d",        "Discord",                               function () helpers.run.run_or_raise("discord",     { class = "discord" }) end, },
        { "M-e s",        "Steam",                                 function () helpers.run.run_or_raise("steam",       { class = "Steam", name = "Steam" }) end, },
        { "M-e t",        "Teams",                                 function () helpers.run.run_or_raise("teams",       { class = "Microsoft Teams %- Preview" }) end, },
        { "M-e k",        "KeePassXC",                             function () helpers.run.run_or_raise("keepassxc",   { class = "KeePassXC" }) end, },
    })

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

    awful.mouse.append_global_mousebindings({
        awful.button({}, 3, function() main_menu:toggle() end),
        awful.button({}, 4, awful.tag.viewprev),
        awful.button({}, 5, awful.tag.viewnext)
    })

    if hotkeys_popup then
        hotkeys_popup:add_keygroups(ezhk.key_groups)
    end
end

function Hotkeys.spawn(cmd)
    return function()
        awful.spawn(cmd)
    end
end

function Hotkeys.colorpicker()
    awful.spawn.with_shell(
        'xcolor -s && notify-send "Color picked" "<span background=\'$(xclip -selection clipboard -o)\'>	$(xclip -selection clipboard -o)		</span>"'
    )
end

function Hotkeys.un_maximize(c)
    c.maximized = not c.maximized
    if c.maximized then
        c.border_width = 0
    else
        c.border_width = beautiful.border_width
    end
    c:raise()
end

function Hotkeys.lua_execute_prompt()
    awful.prompt.run {
        prompt = "Run Lua code: ",
        textbox = awful.screen.focused().prompt.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval",
    }
end

function Hotkeys.only_view_tag(index)
    local screen = awful.screen.focused()
    local tag = screen.tags[index]
    if tag then
        tag:view_only()
        tag:emit_signal("request::activate", tag)
    end
end

function Hotkeys.toggle_tag(index)
    local screen = awful.screen.focused()
    local tag = screen.tags[index]
    if tag then
        awful.tag.viewtoggle(tag)
    end
end

function Hotkeys.move_client_and_view(index)
    if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
            client.focus:move_to_tag(tag)
            tag:view_only()
            tag:emit_signal("request::activate", tag)
        end
    end
end

function Hotkeys.toggle_on_tag(index)
    if client.focus then
        local tag = client.focus.screen.tags[index]
        if tag then
            client.focus:toggle_tag(tag)
        end
    end
end

function Hotkeys.select_layout_by_idx(index)
    local t = awful.screen.focused().selected_tag
    if t then
        t.layout = t.layouts[index] or t.layout
    end
end

function Hotkeys.toggle_single_client_gaps()
    local screen = awful.screen.focused()
    if not screen then
        return
    end
    local selected_tag = screen.selected_tag
    if not selected_tag then
        return
    end

    selected_tag.gap_single_client = not selected_tag.gap_single_client
    awful.layout.arrange(screen)
    show_gaps_popup(selected_tag)
end

function Hotkeys.toggle_all_gaps()
    local screen = awful.screen.focused()
    if not screen then
        return
    end
    local selected_tag = screen.selected_tag
    if not selected_tag then
        return
    end

    if selected_tag.gap == 0 then
        selected_tag.gap = beautiful.useless_gap
    else
        selected_tag.gap = 0
    end
    show_gaps_popup(selected_tag)
end

function Hotkeys.jump_to_previous_client()
    awful.client.focus.history.previous()
    if client.focus then
        client.focus:raise()
    end
end

function Hotkeys.restore_minimized()
    local c = awful.client.restore()
    if c then
        c:activate { raise = true, context = "key.unminimize" }
    end
end

return Hotkeys
