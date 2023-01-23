local gears           = require("gears")
local naughty         = require("naughty")
local awful           = require("awful")
local key             = awful.key
local keyboard        = awful.keyboard

local PermanentScratchpad = require(... .. ".permanent_scratchpad")
local TemporaryScratchpad = require(... .. ".temporary_scratchpad")

local ret = {
    _private = {
        permanent_scratchpads = {},
        temporary_scratchpads = {},
    },
}

local function val_or_default(val, default)
    if val == nil then
        return default
    end
    return val
end

function ret:add(args)
    local scratchpad = PermanentScratchpad:new {
        command             = args.command,
        class               = args.class,
        props               = args.client_props,
        close_on_focus_lost = val_or_default(args.close_on_focus_lost, self.args.close_on_focus_lost),
        reapply_props       = val_or_default(args.reapply_props, self.args.reapply_props),
    }

    if args.hotkey then
        keyboard.append_global_keybindings {
            key {
                modifiers   = args.hotkey.modifiers,
                key         = args.hotkey.key,
                description = args.hotkey.description,
                group       = args.hotkey.group,
                on_press    = function ()
                    scratchpad:toggle()
                end
            }
        }
    end

    self._private.permanent_scratchpads[args.class] = scratchpad
    return scratchpad
end

function ret:add_temp(args)
    local scratchpad = TemporaryScratchpad:new {
        props               = args.client_props,
        close_on_focus_lost = val_or_default(args.close_on_focus_lost, self.args.close_on_focus_lost),
        reapply_props       = val_or_default(args.reapply_props, self.args.reapply_props),
    }

    if args.hotkey then
        keyboard.append_global_keybindings {
            key {
                modifiers   = args.hotkey.modifiers,
                key         = args.hotkey.key,
                description = args.hotkey.description,
                group       = args.hotkey.group,
                on_press    = function ()
                    scratchpad:toggle()
                end
            },
            key {
                    modifiers   = args.hotkey.client_toggle_modifiers,
                    key         = args.hotkey.key,
                    description = "Toggle " .. args.hotkey.description,
                    group       = args.hotkey.group,
                    on_press    = function ()
                        scratchpad:toggle_client()
                    end
            }
        }
    end

    table.insert(self._private.temporary_scratchpads, scratchpad)
    return scratchpad
end

function ret:toggle(class)
    local scratchpad = self._private.scratchpads[class]
    if not scratchpad or not scratchpad.command or not scratchpad.class then
        naughty.notify {
            title = "Missing Scratchpad",
            message = "Scratchpad " .. class " .. is missing or malformed",
        }
        return
    end

    scratchpad:toggle()
end

function ret:init(args)
    self.args = args or {}
    client.connect_signal("request::manage", function (c, context)
        local scratchpad = self._private.permanent_scratchpads[c.class]
        if scratchpad then
            scratchpad:set_client(c)
            if context == "startup" then
                gears.timer.delayed_call(function ()
                    scratchpad:hide()
                end)
            end
        end
    end)
    awesome.connect_signal("exit", function (is_restart)
        if is_restart then
            for _, v in ipairs(self._private.temporary_scratchpads) do
                v:destroy()
            end
        end
    end)
end

return ret
