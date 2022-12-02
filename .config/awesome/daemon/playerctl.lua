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
    -- Default branch, we either have no URL or the file was not found on disk
    else
        current.artUrl = default_cover
        observer:emit_signal("metadata", current)
    end
end

local metadata_format = "'player={{playerName}},status={{status}},volume={{volume}},artist={{artist}},title={{title}},artUrl={{mpris:artUrl}},length={{mpris:length}},'"
awful.spawn.easy_async({ "pkill", "--full", "--uid", os.getenv("USER"), "^playerctl -F" }, function ()
    awful.spawn.with_line_callback("playerctl -F metadata -f " .. metadata_format, {
        stdout = function (line)
            on_metadata_changed(line)
        end
    })

    awful.spawn.with_line_callback("playerctl -F metadata -f '{{position}}'", {
        stdout = function (line)
            current.position = (tonumber(line) or 0) / 1000000
            observer:emit_signal("update_position", current)
        end
    })
end)

-- Connect to signals for handling user inputs
observer:connect_signal("seek", function (_, value)
    if not current.position or math.abs(value - current.position) < seek_debounce_threshold_sec then
        return
    end
    current.position = value
    awful.spawn("playerctl position " .. value)
end)

observer:connect_signal("play", function ()
    awful.spawn("playerctl play")
end)

observer:connect_signal("stop", function ()
    awful.spawn("playerctl stop")
end)

observer:connect_signal("pause", function ()
    awful.spawn("playerctl pause")
end)

observer:connect_signal("play-pause", function ()
    awful.spawn("playerctl play-pause")
end)

observer:connect_signal("next", function ()
    awful.spawn("playerctl next")
end)

observer:connect_signal("previous", function ()
    awful.spawn("playerctl previous")
end)

return observer
