local config = require("config")
local daemon = require("daemon.cpu")

local cpu = require("modules.bar_widgets." .. config.bar.cpu.style):new(config.bar.cpu)

daemon:connect_signal("update", function (_, value)
    cpu:update(value)
end)

return cpu
