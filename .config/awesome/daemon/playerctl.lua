local awful = require("awful")
local gears = require("gears")

local cfg   = require("config")

local observer = gears.object{}
local seek_debounce_threshold_sec = 2
local defaul_cover = cfg.dir.assets .. "/default_album_cover.png"
local current = {
    artist   = "Unknown Artist",
    title    = "Not Playing",
    artUrl   = defaul_cover,
    position = 0,
    length   = 0,
}

-- emit updates once to init default values
observer:emit_signal("metadata", current)
observer:emit_signal("update_position", current)

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

    local artUrl = gears.string.xml_escape(stdout:match(".*artUrl=*(.-),"))
    if artUrl and string.len(artUrl) > 1 then
        current.artUrl = artUrl
    else
        current.artUrl = defaul_cover
    end

    local length = stdout:match(".*length=*(.-),")
    if length then
        current.length = tonumber(length) / 1000000
    end

    observer:emit_signal("metadata", current)
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
            current.position = tonumber(line) / 1000000
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
