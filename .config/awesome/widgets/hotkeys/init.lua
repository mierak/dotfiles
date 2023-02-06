local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local theme = require("theme")

local HotkeysGroup = require("widgets.hotkeys.group")

---@alias Key { key: string, mods: ("Super" | "Shift" | "Control")[], description: string }
---@alias KeyGroups table<string, Key[]>

---@class HotkeysPopup
---@field default_instance HotkeysPopup
---@field container table
---@field widget table
---@field private groups HotkeysGroup[]
---@field key_groups KeyGroups
local HotkeysPopup = {}

---Constructs a new instance of HotkeysPopup
---@return HotkeysPopup
function HotkeysPopup:new()
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.key_groups  = {}
    obj.groups      = {}
    obj.built       = false

    obj.container = wibox.widget {
        layout  = wibox.layout.fixed.horizontal,
        spacing = theme.margin,
    }
    obj.widget = awful.popup {
        visible      = false,
        ontop        = true,
        placement    = awful.placement.centered,
        border_width = theme.dpi(1),
        border_color = theme.active,
        screen       = awful.screen.focused(),
        widget = wibox.widget {
            widget  = wibox.container.margin,
            margins = theme.margin * 2,
            obj.container,
        }
    }

    obj.widget:connect_signal("mouse::leave", function (w)
        w.visible = false
    end)
    obj.widget:connect_signal("button::press", function (w)
        w.visible = false
    end)

    return obj
end

---Adds to the popup
---@param key_groups KeyGroups
function HotkeysPopup:add_keygroups(key_groups)
    for name, group in pairs(key_groups) do
        if not self.key_groups[name] then self.key_groups[name] = {} end
        for _, key in ipairs(group) do
            table.insert(self.key_groups[name], key)
        end
    end
end

---Shows the hotkeys popup widget
function HotkeysPopup:show()
    self.widget.screen = awful.screen.focused()
    self.widget.visible = true
end

---Hides the hotkeys popup widget
function HotkeysPopup:hide()
    self.widget.visible = false
end

---Toggles visibility of the hotkeys popup widget
function HotkeysPopup:toggle()
    if not self.built then
        self:build_column(self.key_groups)
        self.built = true
    end
    if not self.widget.visible then
        self:show()
    else
        self:hide()
    end
end

---Inserts hotkey to a table, creating a group by group name if necessary
---@param hotkey Key
---@param key_groups KeyGroups
---@param group_name string
function HotkeysPopup:insert_hotkey_to(hotkey, key_groups, group_name)
    if not key_groups[group_name] then
        key_groups[group_name] = {}
    end
    table.insert(key_groups[group_name], hotkey)
end

---@param hk Hotkey
function HotkeysPopup:create_hotkey_buttons_widget(hk)
    local hk_widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = theme.margin * 2,
        spacing_widget = {
            widget = wibox.widget.textbox,
            valign = "center",
            halign = "center",
            text   = "+",
        }
    }

    for _, mod in ipairs(hk.modifiers) do
        local mod_widget = hk:create_modifiers_widget(mod)
        hk_widget:add(mod_widget)
    end
    hk_widget:add(hk:create_key_widget())
    return hk_widget
end

---Builds the widget columns recursively
---@param key_groups KeyGroups
function HotkeysPopup:build_column(key_groups)
    ---@type KeyGroups
    local unfinished_key_groups = {}
    local max_rows = 30

    local column_grid = wibox.widget {
        forced_num_cols        = 2,
        layout                 = wibox.layout.grid,
        horizontal_homogeneous = false,
        horizontal_expand      = true,
        horizontal_spacing     = theme.margin,
        vertical_spacing       = theme.margin / 2,
    }
    self.container:add(column_grid)

    -- Sort group names to get predictable results
    local current_row = 1
    local group_names = gears.table.keys(key_groups)
    table.sort(group_names)

    for _, group_name in ipairs(group_names) do
        local group_definition = key_groups[group_name]
        local group            = HotkeysGroup:new { name = group_name }

        -- Increment current row by one if group name is the last row
        -- to skip the last line so we dont end up with group name and nothing else
        -- on the last line
        if current_row == max_rows then
            current_row = current_row + 1
        end

        if current_row > max_rows then
            unfinished_key_groups[group_name] = group_definition
        else
            column_grid:add_widget_at(group:create_title(), current_row, 2)
            current_row = current_row + 1

            for _, kb in ipairs(group_definition) do
                if current_row > max_rows then
                    self:insert_hotkey_to(kb, unfinished_key_groups, group_name)
                else
                    local hk = group:add_hotkey(kb.mods, kb.key, kb.description)
                    local hk_widget = self:create_hotkey_buttons_widget(hk)
                    column_grid:add_widget_at(wibox.widget { widget = wibox.container.place, halign = "right", hk_widget }, current_row, 1)
                    column_grid:add_widget_at(hk:create_description_widget(), current_row, 2)
                    current_row = current_row + 1
                end
            end
        end
    end

    -- Create more columns recursively if we have exceeded the threshold
    if current_row > max_rows then
        self:build_column(unfinished_key_groups)
    end
end

HotkeysPopup.default_instance = HotkeysPopup:new()

return HotkeysPopup

