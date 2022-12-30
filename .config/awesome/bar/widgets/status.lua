local wibox = require("wibox")

local helpers = require("helpers/misc")

local ret = {}

ret.widget = wibox.widget {
    widget = wibox.widget.textbox,
    markup = helpers.colorize { text = "" }
}

function ret.set_text(text)
    ret.widget.markup = helpers.colorize { text = text }
end

return ret
