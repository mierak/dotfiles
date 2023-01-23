-- All code in this file belongs to Bling - https://github.com/BlingCorp/bling and is subject to its license.
-- Minor changes were made to better integrate with current config

local awful = require("awful")
local config = require("config")

local helpers = {}

function helpers.turn_off(c, current_tag)
    if current_tag == nil then
        current_tag = c.screen.selected_tag
    end
    local ctags = {}
    for _, tag in pairs(c:tags()) do
        if tag ~= current_tag then
            table.insert(ctags, tag)
        end
    end
    c:tags(ctags)
    c.sticky = false
end

--- Turn on passed client (add current tag to window's tags)
--
-- @param c A client
function helpers.turn_on(c)
    local current_tag = c.screen.selected_tag
    local ctags = { current_tag }
    for _, tag in pairs(c:tags()) do
        if tag ~= current_tag then
            table.insert(ctags, tag)
        end
    end
    c:tags(ctags)
    c:raise()
    client.focus = c
end
--- Sync two clients
--
-- @param to_c The client to which to write all properties
-- @param from_c The client from which to read all properties
function helpers.sync(to_c, from_c)
    if not from_c or not to_c then
        return
    end
    if not from_c.valid or not to_c.valid then
        return
    end
    if from_c.modal then
        return
    end
    to_c.floating = from_c.floating
    to_c.maximized = from_c.maximized
    to_c.above = from_c.above
    to_c.below = from_c.below
    to_c:geometry(from_c:geometry())
    -- TODO: Should also copy over the position in a tiling layout
end



-- It might actually swallow too much, that's why there is a filter option by classname
-- without the don't-swallow-list it would also swallow for example
-- file pickers or new firefox windows spawned by an already existing one

local window_swallowing_activated = false

-- you might want to add or remove applications here
local parent_filter_list = config.modules.window_swallow.parent_filter_list or {}
local child_filter_list = config.modules.window_swallow.child_filter_list or {}

-- for boolean values the or chain way to set the values breaks with 2 vars
-- and always defaults to true so i had to do this to se the right value...
local swallowing_filter = true

-- check if element exist in table
-- returns true if it is
local function is_in_table(element, table)
    local res = false
    for _, value in pairs(table) do
        if element:match(value) then
            res = true
            break
        end
    end
    return res
end

-- if the swallowing filter is active checks the child and parent classes
-- against their filters
local function check_swallow(parent, child)
    local res = true
    if swallowing_filter then
        local prnt = not is_in_table(parent, parent_filter_list)
        local chld = not is_in_table(child, child_filter_list)
        res = ( prnt and chld )
    end
    return res
end

-- async function to get the parent's pid
-- recieves a child process pid and a callback function
-- parent_pid in format "init(1)---ancestorA(pidA)---ancestorB(pidB)...---process(pid)"
local function get_parent_pid(child_ppid, callback)
    local ppid_cmd = string.format("pstree -A -p -s %s", child_ppid)
    awful.spawn.easy_async(ppid_cmd, function(stdout, stderr, _, _)
        -- primitive error checking
        if stderr and stderr ~= "" then
            callback(stderr)
            return
        end
        local ppid = stdout
        callback(nil, ppid)
    end)
end


-- the function that will be connected to / disconnected from the spawn client signal
local function manage_clientspawn(c)
    -- get the last focused window to check if it is a parent window
    local parent_client = awful.client.focus.history.get(c.screen, 1)
    if not parent_client then
        return
    elseif parent_client.type == "dialog" or parent_client.type == "splash" then
        return
    end

    local parent_pid
    get_parent_pid(c.pid, function(err, ppid)
        if err then
            return
        end
        parent_pid = ppid
    if
        -- will search for "(parent_client.pid)" inside the parent_pid string
        ( tostring(parent_pid):find("("..tostring(parent_client.pid)..")") )
        and check_swallow(parent_client.class, c.class)
    then
        c:connect_signal("unmanage", function()
            if parent_client then
                helpers.turn_on(parent_client)
                helpers.sync(parent_client, c)
            end
        end)

        helpers.sync(c, parent_client)
        helpers.turn_off(parent_client)
    end
    end)
end

-- without the following functions that module would be autoloaded by require("bling")
-- a toggle window swallowing hotkey is also possible that way

local function start()
    client.connect_signal("manage", manage_clientspawn)
    window_swallowing_activated = true
end

local function stop()
    client.disconnect_signal("manage", manage_clientspawn)
    window_swallowing_activated = false
end

local function toggle()
    if window_swallowing_activated then
        stop()
    else
        start()
    end
end

return start
