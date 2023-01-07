local awful = require("awful")
local gears = require("gears")
local helpers = require("helpers")

local observer = gears.object{}

-- CSV: index, vol_mono, vol_left, vol_right, muted, app_name, app_bin
local cmd_list_sinks = "pactl --format=json list sink-inputs | jq -r '.[] | [.index, .volume.mono.value_percent, .volume.\"front-left\".value_percent, .volume.\"front-right\".value_percent, .mute, .properties.\"application.name\", .properties.\"application.process.binary\"] | @csv'"
local csv_line_pattern = "%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-),%s*(.-)\n"

local function split_lines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

local function trim_safe(str, start_idx, end_idx)
    if str and #str > 0 then
        return str:sub(start_idx, end_idx)
    end
    return ""
end

local current_sink_inputs = {}

local function get_all_sink_inputs(callback)
    awful.spawn.easy_async_with_shell(cmd_list_sinks, function (out)
        local sinks = {}
        for line in split_lines(out) do
            -- Group all sink sink inputs by key of "<app_bin><app_name>" and register all indices in the group
            local idx, mono, left, right, muted, app, bin = (line .. "\n"):match(csv_line_pattern)
            if #idx > 0 and (#bin > 0 or #app > 1) then
                local app_name  = trim_safe(app, 2, -2)
                local app_bin   = trim_safe(bin, 2, -2)
                local key = app_name .. app_bin
                local volume   = math.max(tonumber(trim_safe(mono, 2, -3)) or 0, tonumber(trim_safe(left, 2, -3)) or 0, tonumber(trim_safe(right, 2, -3)) or 0)
                if not sinks[key] then
                    sinks[key] = {
                        indices  = { idx },
                        volume   = volume,
                        app_bin  = app_bin,
                        app_name = app_name,
                    }
                    if muted == "true" then sinks[key].muted = true else sinks[key].muted = false end
                else
                    table.insert(sinks[key].indices, idx)
                    sinks[key].muted = sinks[key].muted and muted == "true"
                    if volume > sinks[key].volume then
                        sinks[key].volume = volume
                    end
                end
            end
        end
        current_sink_inputs = sinks
        callback(sinks)
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
            local sink
            local key
            for k, value in pairs(sink_inputs) do
                if helpers.table.contains(value.indices, id) then
                    sink = value
                    key = k
                end
            end
            if not sink or not key then return end
            observer:emit_signal("sink_input_change_" .. key, sink)
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
        for _, index in ipairs(current_sink_inputs[data.key].indices) do
            awful.spawn("pactl set-sink-input-volume " .. index .. " " .. data.value .. "%")
        end
        queued_volume = false
    end)
end)

observer:connect_signal("mute_toggle", function (_, key)
    for _, index in ipairs(current_sink_inputs[key].indices) do
        awful.spawn("pactl set-sink-input-mute " .. index .. " toggle")
    end
end)

observer:connect_signal("refresh", function ()
    get_all_sink_inputs(function (sink_inputs)
        observer:emit_signal("sink_inputs", sink_inputs)
    end)
end)

return observer
