local awful           = require("awful")
local key             = awful.key
local keyboard        = awful.keyboard

local Hotkeys = {}
function Hotkeys:new(modkey)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self.key_to_mod = { M = modkey, S = "Shift", C = "Control" }
    self.global_keybinds = {}
    self.client_keybinds = {}

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

function Hotkeys:global_keybind_group(group_name, keybinds)
    for _, kb in ipairs(keybinds) do
        if kb[4] ~= false then
            table.insert(self.global_keybinds, self:keybind(kb[1], group_name, kb[2], kb[3]))
        end
    end
end

function Hotkeys:client_keybind_group(group_name, keybinds)
    for _, kb in ipairs(keybinds) do
        if kb[4] ~= false then
            table.insert(self.client_keybinds, self:keybind(kb[1], group_name, kb[2], kb[3]))
        end
    end
end


return Hotkeys
