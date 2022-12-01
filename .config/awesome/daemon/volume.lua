local awful = require("awful")
local gears = require("gears")

local observer = gears.object{}

-- CSV: index, vol_mono, vol_left, vol_right, muted, app_name, app_bin, app_icon
local cmd_list_sinks = "pactl --format=json list sink-inputs | jq -r '.[] | [.index, .volume.mono.value_percent, .volume.\"front-left\".value_percent, .volume.\"front-right\".value_percent, .mute, .properties.\"application.name\", .properties.\"application.process.binary\", .properties.\"application.icon_name\"] | @csv'"
local csv_line_pattern = "%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-)\n"

local function split_lines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

local function trim_safe(str, start_idx, end_idx)
    if str and #str > 0 then
        return str:sub(start_idx, end_idx)
    end
    return nil
end

local function get_all_sink_inputs(callback)
    awful.spawn.easy_async_with_shell(cmd_list_sinks, function (out)
        local sink_inputs = {}
        for line in split_lines(out) do
            local idx, mono, left, right, muted, app, bin, icon = (line .. "\n"):match(csv_line_pattern)
            if #bin > 0 and #app > 0 and #idx > 0 then
                local sink_input = {
                    index     = idx,
                    vol_mono  = tonumber(trim_safe(mono, 2, -3)),
                    vol_left  = tonumber(trim_safe(left, 2, -3)),
                    vol_right = tonumber(trim_safe(right, 2, -3)),
                    app_name  = trim_safe(app, 2, -2),
                    app_bin   = trim_safe(bin, 2, -2),
                    app_icon  = trim_safe(icon, 2, -2),
                }
                if muted == "true" then sink_input.muted = true else sink_input.muted = false end
                sink_inputs[idx] = sink_input
                table.insert(sink_inputs, sink_input)
            end
        end
        callback(sink_inputs)
    end)
end

get_all_sink_inputs(function (sink_inputs)
    observer:emit_signal("sink_inputs", sink_inputs)
end)

local function full_refresh()
    get_all_sink_inputs(function (sink_inputs)
        observer:emit_signal("sink_inputs", sink_inputs)
    end)
end

local event_handlers = {
    change = function (id)
        get_all_sink_inputs(function (sink_inputs)
            observer:emit_signal("sink_input_change_" .. id, sink_inputs[id])
        end)
    end,
    new = full_refresh,
    remove = full_refresh,
}

awful.spawn.easy_async({ "pkill", "--full", "--uid", os.getenv("USER"), "^pactl subscribe" }, function ()
    local queued_update = false
    awful.spawn.with_line_callback("/bin/sh -c 'pactl subscribe | grep --line-buffered \"sink-input\"'", {
        stdout = function (line)
            if queued_update then return end

            local event = line:match("'(.+)'")
            local id = line:match("#(.+)")

            if not event_handlers[event] then
                return
            end

            queued_update = true
            gears.timer.delayed_call(function ()
                event_handlers[event](id)
                queued_update = false
            end)
        end,
    })
end)

local queued_volume = false
observer:connect_signal("volume", function (_, data)
    if queued_volume then
        return
    end

    queued_volume = true
    gears.timer.delayed_call(function ()
        awful.spawn("pactl set-sink-input-volume " .. data.index .. " " .. data.value .. "%")
        queued_volume = false
    end)
end)

observer:connect_signal("mute_toggle", function (_, index)
    awful.spawn("pactl set-sink-input-mute " .. index .. " toggle")
end)

observer:connect_signal("refresh", function ()
    get_all_sink_inputs(function (sink_inputs)
        observer:emit_signal("sink_inputs", sink_inputs)
    end)
end)

return observer
