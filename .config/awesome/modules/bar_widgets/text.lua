local wibox     = require("wibox")
local beautiful = require("beautiful")

local helpers = require("helpers")

local TextOnly = {}

function TextOnly:new(args)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.icon = args.icon
    obj.fg = beautiful[args.fg]
    obj.widget = wibox.widget {
        widget = wibox.widget.textbox,
        font = beautiful.fonts.bar,
    }
    obj:update(args.init_val or 0)

    return obj
end

function TextOnly:update(value, format_fn)
    if type(format_fn) == "function" then
        self.widget.markup = helpers.misc.colorize {
            text = format_fn(),
            fg = self.fg
        }
    else
        self.widget.markup = helpers.misc.colorize {
            text = string.format(self.icon .. "%2d%%", value),
            fg = self.fg
        }
    end
end
return TextOnly
