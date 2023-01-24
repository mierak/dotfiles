local awful   = require("awful")

local Scratchpad = {}

function Scratchpad:new(args)
    local a = args or {}
    local obj = {}

    setmetatable(obj, self)
    self.__index = self
    obj.props               = a.props or {}
    obj.class               = a.class
    obj.command             = a.command
    obj.client              = a.client
    obj.close_on_focus_lost = a.close_on_focus_lost or false
    obj.reapply_props       = a.reapply_props or false

    return obj
end

function Scratchpad:_apply_props(props)
    if not self.client or not props then return end

    self.client.floating = props.floating or false
    self.client.sticky = props.sticky or false
    self.client.skip_taskbar = (function() if props.skip_taskbar ~= nil then return props.skip_taskbar else return true end end)()
    if self.client.floating then
        self.client:geometry {
            x = awful.screen.focused().geometry.x + props.geometry.x,
            y = awful.screen.focused().geometry.y + props.geometry.y,
            width = props.geometry.width,
            height = props.geometry.height,
        }
    end
end

function Scratchpad:hide()
    if self.client then
        self.client.sticky = false
        self.client:tags({})
    end
end

function Scratchpad:show()
    if self.client then
        local focused_screen = awful.screen.focused()

        self.client.sticky = self.props.sticky or false -- sticky has to be reapplied as it is set to false in hide
        self.client:tags({ focused_screen.selected_tag })
        self.client.screen = focused_screen

        if self.reapply_props then
            self:_apply_props(self.props)
        end
        self.client:activate()

        if not self.client.floating then
            self.client:to_primary_section()
        end
    end
end

function Scratchpad:connect_signals()
    if self.close_on_focus_lost and self.client then
        local fn = function ()
            self:hide()
        end
        self.client:connect_signal("unfocus", fn)
    end

    self.client:connect_signal("request::unmanage", function ()
        self:set_client(nil)
    end)
end

function Scratchpad:set_client(client)
    self.client = client
    if client then
        self:connect_signals()
        self:_apply_props(self.props)
    end
end

return Scratchpad
