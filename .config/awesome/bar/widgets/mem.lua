local config = require("config")
local daemon = require("daemon.mem")

local mem = require("modules.bar_widgets")(config.bar.mem)

daemon:connect_signal("update", function (_, values)
    if config.bar.mem.style == "text" then
        mem:update(config.bar.mem.icon .. values.used .. "/" .. values.total .. "MiB")
    else
        mem:update(tonumber(values.used / values.total * 100))
    end
end)

-- mem:connect_signal("button::press", function ()
--     require("awful").spawn("alacritty -e htop")
-- end)

return mem
