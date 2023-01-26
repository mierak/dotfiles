local gears  = require("gears")
local awful  = require("awful")

local config = require("config")

local PathStat = {}
function PathStat:new(args)
    local o = {}
    args = args or {}
    setmetatable(o, self)
    self.__index = self
    o.size = args.size
    o.used = args.used
    o.available = args.available
    return o
end
function PathStat:toGiB()
    return {
        size = self.size / 1024,
        used = self.used / 1024,
        available = self.available / 1024,
    }
end
function PathStat:parse(df_input)
    local token_index = 1
    for token in df_input:gmatch("%S+") do
        if token_index == 1 then
            self.used = token
        elseif token_index == 2 then
            self.available = token
        elseif token_index == 3 then
            self.size = token
        end
        token_index = token_index +1
    end
end

local daemon = gears.object {}
daemon.paths = {}

local cmd = "df -B 1M --output=used,avail,size,target"
for _, v in ipairs(config.daemon.fs.locations) do
    cmd = cmd .. " " .. v
    daemon.paths[v] = PathStat:new()
end
cmd = cmd .. " | tail -n" .. #config.daemon.fs.locations

function daemon:update()
    awful.spawn.easy_async_with_shell(cmd, function (stdout)
        local index = 1
        for line in stdout:gmatch("[^\r\n]+") do
            local pathStat = daemon.paths[config.daemon.fs.locations[index]]
            pathStat:parse(line)
            index = index + 1
        end
        self:emit_signal("update", self.paths)
    end)
end

local timer = gears.timer {
    timeout   = config.daemon.fs.update_interval_sec,
    autostart = true,
    call_now  = true,
    callback  = function ()
        daemon:update()
    end
}

daemon:connect_signal("stop", function ()
    timer:stop()
end)

daemon:connect_signal("restart", function ()
    timer:again()
end)

daemon:connect_signal("update_now", function ()
    daemon:update()
end)

return daemon
