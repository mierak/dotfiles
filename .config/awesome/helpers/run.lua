local awful = require("awful")
local ruled = require("ruled")

local ret = {}

function ret.try_find_first_client(match_props)
    local matcher = function (c)
        return ruled.client.match(c, match_props)
    end
    for c in awful.client.iterate(matcher) do
        return c
    end
end

function ret.run_or_raise(spawn_cmd, match_props)
    local client = ret.try_find_first_client(match_props)
    if client then
        client.minimized = false
        client:jump_to()
        return client
    end

    local rule
    rule = {
        id = "tmp-" .. spawn_cmd,
        rule = match_props,
        properties = {
        },
        callback = function (c)
            c:jump_to()
            ruled.client.remove_rule(rule)
        end
    }
    ruled.client.append_rule(rule)
    awful.spawn.easy_async_with_shell("setsid -f " .. spawn_cmd .. "> /dev/null 2>&1", function () end)
end

return ret
