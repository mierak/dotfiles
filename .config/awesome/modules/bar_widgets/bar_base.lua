local wibox = require("wibox")
local theme = require("theme")

local helpers = require("helpers")

---@class BarBase
---@field bar table wibox.widget.progressbar
---@field fg string foreground color of the widget
---@field widget table the widget container
---@field icon table wibox.widget containing this widget's icon
local BarBase = {}

---@param args { fg: string, bar_width: integer, icon: string, init_val: string | integer }?
---@return BarBase
function BarBase:new(args)
    args = args or {}
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.fg = theme[args.fg]
    obj.bar = wibox.widget {
        widget = wibox.widget.progressbar,
        shape = helpers.misc.rounded_rect,
        max_value = 100,
        min_value = 0,
        margins = 1,
        value = 0,
        forced_width = args.bar_width or 50,
        background_color = theme.bg_alt,
        color = obj.fg,
        border_color = theme.active,
    }

    obj.icon = wibox.widget {
        widget = wibox.widget.textbox,
        font = theme.fonts.symbols_bar,
        markup = helpers.misc.colorize { text = args.icon, fg = obj.fg },
    }

    obj:update(args.init_val or 0)

    return obj
end

---Updates the bar value
---@param value integer accepted range: 0-100
function BarBase:update(value)
    self.bar.value = value
end

---Connects signal to the widget container
---@param name string Signal name
---@param fn function Signal callback
function BarBase:connect_signal(name, fn)
    self.widget:connect_signal(name, fn)
end

---Disconnects signal to the widget container
---@param name string Signal name
---@param fn function Signal callback
function BarBase:disconnect_signal(name, fn)
    self.widget:disconnect_signal(name, fn)
end

return BarBase
