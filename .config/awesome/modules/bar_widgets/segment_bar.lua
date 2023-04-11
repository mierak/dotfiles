local wibox     = require("wibox")
local beautiful = require("beautiful")

local helpers = require("helpers")

local BaseBar   = require("modules.bar_widgets.bar_base")

---@class SegmentBar : BarBase
---@field text string
local SegmentBar = BaseBar:new()

---@param args { fg: string, bar_width: integer, icon: string, init_val: string | integer }?
---@return SegmentBar
function SegmentBar:new(args)
    local obj = BaseBar:new(args) --[[@as SegmentBar]]
    setmetatable(obj, self)
    self.__index = self

    obj.text = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.fonts.bar,
        valign = "center",
        halign = "center",
    }

    obj.widget = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        obj.icon,
        obj.text
    }

    return obj
end


function SegmentBar:update(value)
    local count = math.floor(value / 10)
    local result = " "
    for _=1,count do
        result = result .. ""
    end
    for _=1,10-count do
        result = result .. ""
    end
    self.text.markup = helpers.misc.colorize { fg = self.fg, text = result }
end

return SegmentBar
