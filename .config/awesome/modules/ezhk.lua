local awful           = require("awful")
local hotkeys_popup   = require("awful.hotkeys_popup")
local gears           = require("gears")
local key             = awful.key
local keyboard        = awful.keyboard

---@class ModalHotkey
---@field private handlers table
---@field private modifiers table
---@field private key string
---@field private keygrabber table
local ModalHotkey = {}

---@nodiscard
---@param args { modifiers: table, key: string, timeout: integer? }
---return ModalHotkey
function ModalHotkey:new(args)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.handlers = {}
    obj.modifiers = args.modifiers
    obj.key = args.key
    obj.keygrabber = awful.keygrabber {
        timeout = args.timeout or 0.5,
        stop_callback = function (_, stop_key, _, _)
            local handler = obj.handlers[stop_key]
            if not handler then
                return
            end

            handler.fn()
        end,
        allowed_keys = gears.table.join(gears.table.keys(obj.handlers), { args.key }),
        stop_key = gears.table.join(gears.table.keys(obj.handlers), args.modifiers ),
        stop_event = "release",
        root_keybindings = {
            awful.key {
                modifiers   = args.modifiers,
                key         = args.key,
                on_press    = function() end
            },
        }
    }

    return obj
end
function ModalHotkey:add(k, group, description, on_press)
    self.handlers[k] = {
        description = description,
        fn = on_press,
    }
    hotkeys_popup.widget.add_hotkeys({
        [group] = {{
            modifiers = self.modifiers,
            keys = { [self.key .. " " .. k] = description }
        }},
    })
end

---@class Hotkeys
---@field private global_keybinds table
---@field private client_keybinds table
---@field private key_to_mod table
---@field private modal_hotkeys table
local Hotkeys = {}

---@nodiscard
---@param modkey any
---@return Hotkeys
function Hotkeys:new(modkey)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.key_to_mod = { M = modkey, S = "Shift", C = "Control" }
    obj.global_keybinds = {}
    obj.client_keybinds = {}
    obj.modal_hotkeys = {}

    return obj
end

function Hotkeys:finalize()
    keyboard.append_global_keybindings(self.global_keybinds)
    keyboard.append_client_keybindings(self.client_keybinds)
end

function Hotkeys:parse_keybind_string(keybind)
    local keys = {}
    for k in keybind:gmatch("[^%-]+") do
        table.insert(keys, k)
    end
    local index = 1
    local modkeys = {}
    local k
    for _, v in ipairs(keys) do
        if index < #keys then
            table.insert(modkeys, self.key_to_mod[v])
        else
            k = v
        end
        index = index + 1
    end
    return { mod = modkeys, key = k }
end

function Hotkeys:keybind(keys, group, description, on_press)
    local ks = self:parse_keybind_string(keys)
    if ks.key == "numrow" or ks.key == "arrows" or ks.key == "fkeys" or ks.key == "numpad" then
        return key {
            modifiers = ks.mod,
            keygroup = ks.key,
            group = group,
            description = description,
            on_press = on_press
        }
    end
    return key {
        modifiers = ks.mod,
        key = ks.key,
        group = group,
        description = description,
        on_press = on_press
    }
end

function Hotkeys:modal_keybind(keys, group, description, on_press)
    local split = {}
    for s in keys:gmatch("[^% ]+") do
        table.insert(split, s)
    end
    local trigger = split[1]
    local sequence = split[2]
    local parsed = self:parse_keybind_string(trigger)
    if not self.modal_hotkeys[trigger] then
        self.modal_hotkeys[trigger] = ModalHotkey:new { modifiers = parsed.mod, key = parsed.key }
    end
    self.modal_hotkeys[trigger]:add(sequence, group, description, on_press)
end

---Creates a global keybinding
---@param group_name string
---@param keybinds { [1]: string, [2]: string, [3]: function, [4]: boolean? }[]
function Hotkeys:global_keybind_group(group_name, keybinds)
    for _, kb in ipairs(keybinds) do
        if kb[4] ~= false then
            if kb[1]:find(" ") then
                self:modal_keybind(kb[1], group_name, kb[2], kb[3])
            else
                table.insert(self.global_keybinds, self:keybind(kb[1], group_name, kb[2], kb[3]))
            end
        end
    end
end

---Creates a client keybinding
---@param group_name string
---@param keybinds { [1]: string, [2]: string, [3]: function, [4]: boolean? }[]
function Hotkeys:client_keybind_group(group_name, keybinds)
    for _, kb in ipairs(keybinds) do
        if kb[4] ~= false then
            table.insert(self.client_keybinds, self:keybind(kb[1], group_name, kb[2], kb[3]))
        end
    end
end

function Hotkeys:modal_hotkey_group(group_name, keybinds)
    for _, kb in ipairs(keybinds) do
        if kb[4] ~= false then
            local split = {}
            for s in kb[1]:gmatch("[^% ]+") do
                table.insert(split, s)
            end
            local trigger = split[1]
            local sequence = split[2]
            local parsed = self:parse_keybind_string(trigger)
            if not self.modal_hotkeys[trigger] then
                self.modal_hotkeys[trigger] = ModalHotkey:new { modifiers = parsed.mod, key = parsed.key }
            end
            self.modal_hotkeys[trigger]:add(sequence, group_name, kb[2], kb[3])
        end
    end
end


return Hotkeys
