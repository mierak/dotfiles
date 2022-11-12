local gears     = require("gears")
local wibox     = require("wibox")
local awful     = require("awful")
local beautiful = require("beautiful")

local helpers = {
    table = {},
}

function helpers.colorize(args)
    return string.format('<span color="%s">%s</span>', args.fg or beautiful.fg_normal, args.text)
end

function helpers.to_pill(args)
    return wibox.container.background(
        wibox.container.margin(args.widget, 10, 10),
        args.bg or beautiful.bg_alt,
        gears.shape.rounded_bar
    )
end

function helpers.table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

function helpers.table.to_string(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. helpers.table.to_string(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function helpers.vertical_spacer(height)
    return wibox.widget {
        forced_height = height,
        layout = wibox.layout.fixed.vertical,
    }
end

function helpers.text_button(args)
    if not args.hover then args.hover = {} end

    local buttons = {}
    if args.on_click then
        table.insert(buttons, awful.button({}, 1, function () args.on_click() end))
    end
    if args.on_right_click then
        table.insert(buttons, awful.button({}, 1, function () args.on_right_click() end))
    end

    local button = wibox.widget {
        markup  = helpers.colorize { text = args.text, fg = args.fg or beautiful.fg_norm },
        font    = args.font or beautiful.font_symbols,
        halign  = args.align,
        widget  = wibox.widget.textbox,
        buttons = buttons,
    }

    button:connect_signal("mouse::enter", function (self)
       self.backup = self.markup
       self.markup = helpers.colorize { text = args.text, fg = args.hover.fg or beautiful.active }
       local w = mouse.current_wibox
       if w then
           self.backup_cursor = w.cursor
           w.cursor = "hand1"
       end
    end)

    button:connect_signal("mouse::leave", function (self)
       self.markup = self.backup
       local w = mouse.current_wibox
       if w then
           w.cursor = self.backup_cursor
       end
    end)

    return button
end

local function tchelper(first, rest)
   return first:upper()..rest:lower()
end

function helpers.title_case(str)
    return str:gsub("(%a)([%w_']*)", tchelper)
end

helpers.data_dir = os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share"
helpers.config_dir = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"
helpers.icon_dir = helpers.config_dir .. "/awesome/icons"

return helpers
