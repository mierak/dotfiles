local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")

local helpers = {
    table = {},
}

function helpers.colorize(args)
    return string.format("<span color=\"%s\">%s</span>", args.fg or beautiful.fg_normal, args.text)
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

helpers.data_dir = os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share"
helpers.config_dir = os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config"

return helpers
