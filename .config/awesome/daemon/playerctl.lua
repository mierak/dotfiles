local awful = require("awful")
local gears = require("gears")

local cfg   = require("config")

local observer = gears.object{}
local seek_debounce_threshold_sec = 2
local default_cover = cfg.dir.assets .. "/default_album_cover.png"
local current = {
    artist   = "Unknown Artist",
    title    = "Not Playing",
    artUrl   = default_cover,
    position = 0,
    length   = 0,
}

-- emit updates once to init default values
gears.timer.delayed_call(function ()
    observer:emit_signal("metadata", current)
    observer:emit_signal("update_position", current)
end)

local function on_metadata_changed(stdout)
    current = {}

    local status = gears.string.xml_escape(stdout:match(".*status=*(.-),")) or ""
    current.status = status

    local title = gears.string.xml_escape(stdout:match(".*title=*(.-),")) or ""
    if #title == 0 then
        current.title = "Unknown"
    else
        current.title = title
    end

    local artist = gears.string.xml_escape(stdout:match(".*artist=*(.-),")) or ""
    if #artist == 0 then
        current.artist = "Unknown Artist"
    else
        current.artist = artist
    end

    local length = tonumber(stdout:match(".*length=*(.-),"))
    if length then
        current.length = length / 1000000
    end

    -- TODO: Different (async) way to check existence of artUrl
    local artUrl = gears.string.xml_escape(stdout:match(".*artUrl=*(.-),"))
    -- Fix "file://" path, and check if the file exists
    if artUrl and string.len(artUrl) > 1 and artUrl:match("^file:") then
        local url = artUrl:gsub("file://", "")
        awful.spawn.easy_async("test -f \"" .. url .. "\"", function (_, _, _, exit_code)
            if exit_code == 0 then
                current.artUrl = url
            else
                current.artUrl = default_cover
            end
            observer:emit_signal("metadata", current)
        end)
    -- Download HTTP image from the internet
    elseif artUrl and string.len(artUrl) > 1 and artUrl:match("^http") then
        local filePath = "/tmp/current_thumb.jpg"
        awful.spawn.easy_async({ "curl", "-L", "-s", artUrl, "-o", filePath }, function ()
            current.artUrl = filePath
            observer:emit_signal("metadata", current)
        end)
    -- Support Mopidy-local artUrl format
    elseif artUrl and string.len(artUrl) > 1 and artUrl:match("^/local") then
        current.artUrl = cfg.dir.data .. "/mopidy/local/images/" .. artUrl:match("/local/(.*)")
        observer:emit_signal("metadata", current)
    -- Support Mopidy-Youtube artUrl format
    elseif artUrl and string.len(artUrl) > 1 and artUrl:match("^/youtube") then
        current.artUrl = cfg.dir.cache .. "/mopidy" .. artUrl
        observer:emit_signal("metadata", current)
    -- Default branch, we either have no URL or the file was not found on disk
    else
        current.artUrl = default_cover
        observer:emit_signal("metadata", current)
    end
end

local players = cfg.playerctl.players

local metadata_format = "'status={{status}},volume={{volume}},artist={{artist}},title={{title}},artUrl={{mpris:artUrl}},length={{mpris:length}},'"
local metadata_cmd = "playerctl -p " .. table.concat(players, ",") .." -F metadata -f " .. metadata_format
local position_cmd = "playerctl -p " .. table.concat(players, ",") .." -F metadata -f '{{position}}'"
awful.spawn.easy_async({ "pkill", "--full", "--uid", os.getenv("USER"), "^playerctl -F" }, function ()
    local pids = {}
    awful.spawn.with_line_callback("playerctl -F -p " .. table.concat(players, ",") .. " status", {
        stdout = function (status)
            if status == "Playing" and #pids == 0 then
                local m_pid = awful.spawn.with_line_callback(metadata_cmd, {
                    stdout = function (line)
                        on_metadata_changed(line)
                    end
                })

                local p_pid = awful.spawn.with_line_callback(position_cmd, {
                    stdout = function (line)
                        current.position = (tonumber(line) or 0) / 1000000
                        observer:emit_signal("update_position", current)
                    end
                })
                pids = { m_pid, p_pid }
            elseif status == "Stopped" then
                if #pids > 1 then
                    awful.spawn("kill -9 " .. pids[1] .. " " .. pids[2])
                end
                pids = {}
            end
        end
    })

end)

-- Connect to signals for handling user inputs
observer:connect_signal("seek", function (_, value)
    if not current.position or math.abs(value - current.position) < seek_debounce_threshold_sec then
        return
    end
    current.position = value
    awful.spawn("playerctl -p " .. table.concat(players, ",") .. " position " .. value)
end)

observer:connect_signal("play", function ()
    awful.spawn("playerctl -p " .. table.concat(players, ",") .. " play")
end)

observer:connect_signal("stop", function ()
    awful.spawn("playerctl -p " .. table.concat(players, ",") .. " stop")
end)

observer:connect_signal("pause", function ()
    awful.spawn("playerctl -p " .. table.concat(players, ",") .. " pause")
end)

observer:connect_signal("play-pause", function ()
    awful.spawn("playerctl -p " .. table.concat(players, ",") .. " play-pause")
end)

observer:connect_signal("next", function ()
    awful.spawn("playerctl -p " .. table.concat(players, ",") .. " next")
end)

observer:connect_signal("previous", function ()
    awful.spawn("playerctl -p " .. table.concat(players, ",") .. " previous")
end)

return observer
