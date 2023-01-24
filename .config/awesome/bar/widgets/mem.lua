local config = require("config")
local daemon = require("daemon.mem")

local mem = require("modules.bar_widgets." .. config.bar.mem.style):new(config.bar.mem)

daemon:connect_signal("update", function (_, values)
    mem:update(tonumber(values.used / values.total * 100), function () return config.bar.mem.icon .. values.used .. "/" .. values.total .. "MiB" end)
end)

return mem
