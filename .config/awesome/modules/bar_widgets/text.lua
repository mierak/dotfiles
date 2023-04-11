local wibox = require("wibox")
local theme = require("theme")

local helpers = require("helpers")

local TextOnly = {}

function TextOnly:new(args)
    local obj = {}
    setmetatable(obj, self)
    self.__index = self

    obj.icon = args.icon or ""
    obj.fg = theme[args.fg]
    obj.widget = wibox.widget {
        widget = wibox.widget.textbox,
        font = theme.fonts.bar,
    }
    obj:update(args.init_val or 0)

    return obj
end

function TextOnly:update(value)
    if type(value) == "string" then
        self.widget.markup = helpers.misc.colorize {
            text = value,
            fg = self.fg,
        }
    else
        self.widget.markup = helpers.misc.colorize {
            text = string.format(
                '<span font="%s">%s</span><span font="%s">%2d%%</span>',
                theme.fonts.symbols_bar,
                self.icon,
                theme.fonts.bar,
                value
            ),
            fg = self.fg,
        }
    end
end

function TextOnly:connect_signal(name, fn)
    self.widget:connect_signal(name, fn)
end

function TextOnly:disconnect_signal(name, fn)
    self.widget:disconnect_signal(name, fn)
end

return TextOnly
