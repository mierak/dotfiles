local wibox = require("wibox")
local theme = require("theme")

local helpers = require("helpers")

local mod_to_display = {
    Mod1    = "Alt",
    Mod4    = "Super",
    Control = "Ctrl",
    Shift   = "Shift",
}

local key_to_display = {
    numrow   = "0-9",
    numpad   = "Num 0-9",
    arrows   = "    ",
    Right    = " ",
    Left     = " ",
    Up       = " ",
    Down     = " ",
    Escape   = "󱊷 ",
    fkeys    = "F1-12",
    Return   = "󰌑 ",
    space    = " 󱁐  ",
    vimotion = "hjkl"
}

---@class Hotkey
---@field modifiers table
---@field key string
---@field description string
local Hotkey = {}

---@nodiscard
---@param args { modifiers: table, key: string, description: string }
---@return Hotkey
function Hotkey:new(args)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.description = args.description
    obj.key         = args.key
    obj.modifiers   = args.modifiers

    return obj
end

---@nodiscard
---Constructs texbox for the given modifier key
---@param mod string Modifier key
---@return table awful.widget.textbox
function Hotkey:create_modifiers_widget(mod)
    return wibox.widget {
        widget    = wibox.widget.textbox,
        ellipsize = "none",
        halign    = "center",
        markup    = helpers.misc.colorize { text = " " .. mod_to_display[mod] .. " ", fg = theme.color0, bg = "#9f9f9f" }
    }
end

---@nodiscard
---Constructs texboxes for the given key
---@return table awful.widget.textboxes in a horizontal layout
function Hotkey:create_key_widget()
    local hotkey_container = wibox.widget {
        layout  = wibox.layout.fixed.horizontal,
        spacing = theme.margin,
    }

    for v in self.key:gmatch("[^% ]+") do
        hotkey_container:add(wibox.widget {
            widget = wibox.widget.textbox,
            font   = theme.fonts.base_bold .. "11",
            markup = helpers.misc.colorize { text = " " .. (key_to_display[v] or v) .. " ", fg = theme.color0, bg = "#9f9f9f" },
        })
    end
    return hotkey_container
end

---@nodiscard
---Creates a textbox widget with the key description
---@return table awful.widget.textbox
function Hotkey:create_description_widget()
    return wibox.widget {
        text   = self.description,
        widget = wibox.widget.textbox,
    }
end

return Hotkey
