local awful           = require("awful")
local beautiful       = require("beautiful")

local cfg             = require("config")
local show_gaps_popup = require("widgets/gaps_popup")
local ezhk            = require("modules.ezhk"):new(cfg.modkey)

local Hotkeys = {}
function Hotkeys:init(hotkeys_popup, main_menu)
    ezhk:global_keybind_group("Awesome", {
        { "M-S-q",        "Quit Awesome",                          awesome.quit },
        { "M-S-r",        "Restart Awesome",                       awesome.restart },
        { "M-Return",     "Open a Terminal",                       function() awful.spawn(cfg.terminal) end },
        { "M-s",          "Show Help",                             hotkeys_popup.show_help },
        { "M-w",          "Show Main Menu",                        function () main_menu:show() end },
        { "M-x",          "Lua Execute Prompt",                    self.lua_execute_prompt },
        { "M-`",          "Toggle Sidebar",                        function() awesome.emit_signal("sidebar::toggle") end,     cfg.sidebar.enabled },
    })

    ezhk:global_keybind_group("Tag", {
        { "M-Left",       "View Previous",                         awful.tag.viewprev },
        { "M-Right",      "View Next",                             awful.tag.viewnext },
        { "M-Escape",     "View Last",                             awful.tag.history.restore },
        { "M-numrow",     "Only View Tag",                         self.only_view_tag },
        { "M-C-numrow",   "Toggle Tag",                            self.toggle_tag },
        { "M-S-numrow",   "Move Focused Client to Tag and View",   self.move_client_and_view },
        { "M-S-C-numrow", "Toggle Focused Client on Tag",          self.toggle_on_tag },
    })

    ezhk:global_keybind_group("Layout", {
        { "M-S-l",        "Increase Number of Clients in Master",  function() awful.tag.incnmaster(1, nil, true) end },
        { "M-S-h",        "Decrease Number of Clients in Master",  function() awful.tag.incnmaster(-1, nil, true) end },
        { "M-S-C-l",      "Increase Number of Columns",            function() awful.tag.incncol(1, nil, true) end },
        { "M-S-C-h",      "Decrease Number of Columns",            function() awful.tag.incncol(-1, nil, true) end },
        { "M-l",          "Increase Master Width",                 function() awful.tag.incmwfact(0.05) end },
        { "M-h",          "Decrease Master Width",                 function() awful.tag.incmwfact(-0.05) end },
        { "M-numpad",     "Select Layout Directly",                self.select_layout_by_idx }
    })

    ezhk:global_keybind_group("Gaps", {
        { "M-p",          "Toggle Single Client Gaps",             self.toggle_single_client_gaps },
        { "M-o",          "Toggle All Gaps",                       self.toggle_all_gaps },
    })

    ezhk:global_keybind_group("Screen", {
        { "M-,",          "Focus Left Screen",                     function() awful.screen.focus(cfg.screen.left.index) end,   cfg.screen.left},
        { "M-.",          "Focus Middle Screen",                   function() awful.screen.focus(cfg.screen.middle.index) end, cfg.screen.middle },
        { "M-/",          "Focus Right Screen",                    function() awful.screen.focus(cfg.screen.right.index) end,  cfg.screen.right },
        { "M-C-j",        "Focus Next Screen",                     function() awful.screen.focus_relative(1) end },
        { "M-C-k",        "Focus Previous Screen",                 function() awful.screen.focus_relative(-1) end },
    })

    ezhk:global_keybind_group("Client", {
        { "M-u",          "Jump to Urgent Client",                 awful.client.urgent.jumpto },
        { "M-C-Tab",      "Jump to Previous Client on Screen",     self.jump_to_previous_client },
        { "M-C-n",        "Restore Minimized",                     self.restore_minimized },
        { "M-j",          "Focus Next/Previous Client",            function() awful.client.focus.byidx(1) end },
        { "M-k",          "Focus Next/Previous Client",            function() awful.client.focus.byidx(-1) end },
        { "M-S-j",        "Swap Client With Next/Previous Client", function() awful.client.swap.byidx(1) end },
        { "M-S-k",        "Swap Client With Next/Previous Client", function() awful.client.swap.byidx(-1) end },
    })

    ezhk:client_keybind_group("Client", {
        { "M-S-,",        "Move to Left Screen",                   function(c) c:move_to_screen(cfg.screen.left.index) end,   cfg.screen.left },
        { "M-S-.",        "Move to Middle Screen",                 function(c) c:move_to_screen(cfg.screen.middle.index) end, cfg.screen.middle },
        { "M-S-/",        "Move to Right Screen",                  function(c) c:move_to_screen(cfg.screen.right.index) end,  cfg.screen.right },
        { "M-f",          "Toggle Fullscreen",                     function(c) c.fullscreen = not c.fullscreen; c:raise() end },
        { "M-q",          "Kill Client",                           function(c) c:kill() end },
        { "M-S-Return",   "Move to Master",                        function(c) c:swap(awful.client.getmaster()) end },
        { "M-t",          "Toggle Floating",                       awful.client.floating.toggle },
        { "M-n",          "Minimize Client",                       function(c) c.minimized = true end },
        { "M-m",          "(Un)maximize",                          self.un_maximize },                                                               -- Remove? I use fullscreen instead anyway
        { "M-C-m",        "(Un)maximize Vertically",               function(c) c.maximized_vertical = not c.maximized_vertical; c:raise() end },     -- Remove? I use fullscreen instead anyway
        { "M-S-m",        "(Un)maximize Horizontally",             function(c) c.maximized_horizontal = not c.maximized_horizontal; c:raise() end }, -- Remove? I use fullscreen instead anyway
        { "M-C-space",    "Toggle Keep on Top",                    function(c) c.ontop = not c.ontop end },
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

    ezhk:finalize()
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
        history_path = awful.util.get_cache_dir() .. "/history_eval"
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
    if tag then awful.tag.viewtoggle(tag) end
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
        if tag then client.focus:toggle_tag(tag) end
    end
end

function Hotkeys.select_layout_by_idx(index)
    local t = awful.screen.focused().selected_tag
    if t then t.layout = t.layouts[index] or t.layout end
end

function Hotkeys.toggle_single_client_gaps()
    local screen = awful.screen.focused()
    if not screen then return end
    local selected_tag = screen.selected_tag
    if not selected_tag then return end

    selected_tag.gap_single_client = not selected_tag.gap_single_client
    awful.layout.arrange(screen)
    show_gaps_popup(selected_tag)
end

function Hotkeys.toggle_all_gaps()
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

function Hotkeys.jump_to_previous_client()
    awful.client.focus.history.previous()
    if client.focus then client.focus:raise() end
end

function Hotkeys.restore_minimized()
    local c = awful.client.restore()
    if c then
        c:activate{raise = true, context = "key.unminimize"}
    end
end

return Hotkeys
