local beautiful = require("beautiful")
local wibox     = require("wibox")

local helpers   = require("helpers")

local styles = {
    month = {
        padding      = 20,
        fg_color     = beautiful.color7,
        bg_color     = beautiful.bg_alt.."00",
        border_width = 0,
    },
    normal = {
        markup   = function (t) return '<span font="' .. beautiful.base_font .. '12">' .. t .. '</span>' end
    },
    focus = {
        fg_color = beautiful.color4,
        bg_color = beautiful.color5.."00",
        border_width = 2,
        markup   = function (t) return '<span font="' .. beautiful.base_font .. '12">' .. t .. '</span>' end
    },
    header = {
        fg_color = beautiful.color4,
        bg_color = beautiful.color1.."00",
        markup   = function (t) return '<span font="' .. beautiful.base_font .. '16">' .. t .. '</span>' end
    },
    monthheader = {
        fg_color = beautiful.color4,
        bg_color = beautiful.color1.."00",
        markup   = function (t) return '<span font="' .. beautiful.base_font .. '16">' .. t .. '</span>' end
    },
    weekday = {
        fg_color = beautiful.color7,
        bg_color = beautiful.color1.."00",
        markup   = function (t) return '<span font="' .. beautiful.base_font .. '14">' .. t .. '</span>' end
    },
}

local current_date = os.date("*t")
local function change_month(calendar, new_month)
    if new_month == current_date.month then
        calendar.date = current_date
    else
        calendar.date = { month = new_month, year = calendar.date.year }
    end
end


local function apply_cell_style(widget, props)
    widget.align = "center"
    return wibox.widget {
        {
            widget,
            margins        = (props.padding or 2) + (props.border_width or 0),
            widget         = wibox.container.margin
        },
        shape              = props.shape,
        shape_border_color = props.border_color or beautiful.bg_alt,
        shape_border_width = props.border_width or 0,
        fg                 = props.fg_color or beautiful.color7,
        bg                 = props.bg_color or beautiful.color0.."00",
        widget             = wibox.container.background
    }
end

local function decorate_cell(widget, flag, prev_button, next_button)
    local props = styles[flag] or {}
    if props.markup and widget.get_text and widget.set_markup then
        widget:set_markup(props.markup(widget:get_text()))
    end
    if flag == "monthheader" or flag == "header" then
        return wibox.widget {
            layout = wibox.layout.align.horizontal,
            prev_button,
            apply_cell_style(widget, props),
            next_button,
        }
    end
    return apply_cell_style(widget, props)
end

local function create(args)
    local params = args or {}
    local ret    = {}

    local next = helpers.text_button {
        text         = "  ",
        align        = "right",
        fg       = beautiful.active,
        hover    = {
            fg = beautiful.color4,
        },
        on_click     = function ()
            change_month(ret.calendar, ret.calendar.date.month + 1)
        end,
    }

    local prev = helpers.text_button {
        text         = "  ",
        align        = "left",
        fg       = beautiful.active,
        hover    = {
            fg = beautiful.color4,
        },
        on_click     = function ()
            change_month(ret.calendar, ret.calendar.date.month -1)
        end,
    }

    ret.calendar     = wibox.widget {
        widget       = wibox.widget.calendar.month,
        forced_width = params.width or 350,
        date         = current_date,
        flex_height  = true,
        fn_embed     = function (widget, flag, _) return decorate_cell(widget, flag, prev, next) end,
    }

    function ret.reset()
        ret.calendar.date = current_date
    end

    return ret
end

return create
