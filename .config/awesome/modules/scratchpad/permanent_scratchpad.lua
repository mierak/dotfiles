local awful   = require("awful")
local naughty = require("naughty")
local ruled   = require("ruled")

local Scratchpad = require("modules.scratchpad.abstract_scratchpad")

local PermanentScratchpad = Scratchpad:new()

function PermanentScratchpad:apply_props()
    self._apply_props(self.props)
end

function PermanentScratchpad:toggle()
    if not self.client and not self:try_find_client() then
        self:spawn()
        return
    end

    if self.client.first_tag then
        self:hide()
    else
        self:show()
    end
end

function PermanentScratchpad:spawn()
    if self.spawning then
        return
    end
    self.spawning = true
    awful.spawn.easy_async(self.command, function ()
        self.spawning = false
    end)
end

function PermanentScratchpad:try_find_client()
    local clients = {}
    local matcher = function (c)
        return ruled.client.match(c, { class = self.class })
    end
    for c in awful.client.iterate(matcher) do
        clients[#clients+1] = c
    end
    if #clients > 1 then
        naughty.notify {
            title = "Too many clients",
        }
    end
    if #clients > 0 then
        self:set_client(clients[1])
        return clients[1]
    end
    return nil
end

return PermanentScratchpad
