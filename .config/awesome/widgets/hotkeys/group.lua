local wibox = require("wibox")

local theme = require("theme")

local helpers = require("helpers")

local Hotkey = require("widgets.hotkeys.hotkey")

---@class HotkeysGroup
---@field hotkeys Hotkey[]
---@field private name string
local HotkeysGroup = {}

---@nodiscard
---@param args { name: string }
---@return HotkeysGroup
function HotkeysGroup:new(args)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    obj.name = args.name
    obj.hotkeys = {}

    return obj
end

---@param mods table
---@param key string
---@param description string
---@return Hotkey
function HotkeysGroup:add_hotkey(mods, key, description)
    local hk = Hotkey:new { key = key, modifiers = mods, description = description }
    table.insert(self.hotkeys, hk)
    return hk
end

---@nodiscard
---@return table wibox.widget.textbox
function HotkeysGroup:create_title()
    return wibox.widget {
        widget = wibox.widget.textbox,
        halign = "left",
        font   = theme.fonts.base_bold .. "11",
        markup = helpers.misc.colorize { text = helpers.string.pad(self.name, " ", 30), bg = theme.bg_alt, fg = theme.fg_normal },
    }
end

return HotkeysGroup
