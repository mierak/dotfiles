local awful = require("awful")

local Scratchpad = require("modules.scratchpad.abstract_scratchpad")

local TemporaryScratchpad = Scratchpad:new()

function TemporaryScratchpad:backup_props()
    self.props_backup = {
        geometry = {
            x = self.client:geometry().x,
            y = self.client:geometry().y,
            width = self.client:geometry().width,
            height = self.client:geometry().height,
        },
        floating = self.client.floating,
        sticky = self.client.sticky,
        skip_taskbar = self.client.skip_taskbar,
        first_tag = self.client.first_tag,
    }
    self._apply_props(self.props_backup)
end

function TemporaryScratchpad:toggle()
    if not self.client then return end
     if self.client.first_tag then
        self:hide()
    else
        self:show()
    end
end

function TemporaryScratchpad:apply_props(args)
    if args.from_backup then
        self:_apply_props(self.props_backup)
    else
        self:_apply_props(self.props)
    end

    if args.is_restart then
        self.client:tags({ self.props_backup.first_tag })
    end
end

function TemporaryScratchpad:set_client(client)
    self.client = client
    if client then
        self:backup_props()
        self:connect_signals()
        self:_apply_props(self.props)
    end
end

function TemporaryScratchpad:toggle_client()
    -- Disallow toggling client off scratchpad unless it is visible so we dont end up with invisible clients
    if self.client and not self.client.active then
        return
    end
    if self.client then
        self:apply_props { from_backup = true }
        self:set_client(nil)
        return
    end
    local cl
    local matcher = function (c)
        if c.active then
            return true
        end
        return false
    end
    for c in awful.client.iterate(matcher) do
        cl = c
    end
    self:set_client(cl)
end

function TemporaryScratchpad:destroy()
    if self.client then
        self:apply_props { from_backup = true, is_restart = true }
    end
    self:set_client(nil)
end

return TemporaryScratchpad
