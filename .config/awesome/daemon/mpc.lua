local awful   = require("awful")
local gears   = require("gears")

local config  = require("config")
local helpers = require("helpers")

local default_album_cover = config.dir.assets .. "/default_album_cover.png"
local seek_debounce_threshold_sec = 2

local daemon = gears.object {
    enable_properties = false,
    enable_auto_signals = false,
}

daemon.position_timer = gears.timer {
    autostart = false,
    call_now = false,
    single_shot = false,
    timeout = config.mpc.update_interval,
    callback = function ()
        awful.spawn.easy_async("mpc status '%currenttime%'", function (stdout)
            daemon.data.position = helpers.string.time_to_seconds(stdout)
            daemon:emit_position()
        end)
    end
}

function daemon:reset()
    self.data = {
        artUrl = default_album_cover,
        artist = "Unknown Artist",
        title = "Unknown",
        length = 0,
        position = 0,
        status = "stopped"
    }
    self:emit_metadata()
    self:emit_position()
end

function daemon:try_find_cover_in_song_dir()
    local cover_path = config.dir.music .. "/" .. self.data.file:match("(.+)/") .. "/cover.jpg"
    awful.spawn.easy_async("test -f \"" .. cover_path .. "\"", function (_, _, _, exit_code)
        if exit_code == 0 then
            self.data.artUrl = cover_path
        else
            self.data.artUrl = default_album_cover
        end
        self:emit_metadata()
    end)
end

function daemon:extract_album_cover()
    -- Try to extract embedded art in the file
    awful.spawn.easy_async_with_shell("ffmpeg -y -i \"" .. config.dir.music .. "/" .. self.data.file .. "\" -filter:v 'crop=in_h:in_h' /tmp/awm_mpd_cover.jpg", function (_, _, _, code)
        if code ~= 0 then
            -- If we fail, we try to look inside the album directory for "cover.jpg", TODO: handle other possibilities of cover name
            self:try_find_cover_in_song_dir()
        else
            self.data.artUrl = "/tmp/awm_mpd_cover.jpg"
            self:emit_metadata()
        end
    end)
end

function daemon:update()
    awful.spawn.easy_async("mpc status 'status=%state%@@@volume=%volume%@@@position=%currenttime%@@@'", function (stdout_status)
        self.data.status = stdout_status:match(".*status=*(.-)@@@")
        self.data.position = helpers.string.time_to_seconds(stdout_status:match(".*position=*(.-)@@@") or "")
        self.data.volume = stdout_status:match(".*volume=*(.-)@@@")

        if self.data.status == "playing" then
            if config.mpc.enable_position_update then
                self.position_timer:again()
            end
            awful.spawn.easy_async("mpc -f 'artist=%artist%@@@title=%title%@@@length=%time%@@@file=%file%@@@'", function (stdout)
                self.data.artist = gears.string.xml_escape(stdout:match(".*artist=*(.-)@@@")) or ""
                self.data.title = gears.string.xml_escape(stdout:match(".*title=*(.-)@@@")) or ""
                self.data.file = stdout:match(".*file=*(.-)@@@")
                self.data.length = helpers.string.time_to_seconds(stdout:match(".*length=*(.-)@@@") or "")
                self:extract_album_cover()
                self:emit_position()
            end)
        else
            self.position_timer:stop()
            self:emit_metadata()
        end
    end)
end

function daemon:emit_metadata()
    self:emit_signal("metadata", self.data)
end

function daemon:emit_position()
    self:emit_signal("update_position", self.data)
end

gears.timer.delayed_call(function ()
    daemon:reset()
    daemon:update()
end)

awful.spawn.easy_async({ "pkill", "--full", "--uid", os.getenv("USER"), "mpc idleloop" }, function ()
    awful.spawn.with_line_callback("sh -c 'mpc idleloop player'", {
        stdout = function ()
            daemon:update()
        end
    })
end)

-- Connect to signals for handling user inputs
daemon:connect_signal("seek", function (self, value)
    if not self.data.position or math.abs(value - self.data.position) < seek_debounce_threshold_sec then
        return
    end
    self.data.position = value
    awful.spawn("mpc seek " .. value)
end)

daemon:connect_signal("play", function ()
    awful.spawn("mpc play")
end)

daemon:connect_signal("stop", function ()
    awful.spawn("mpc stop")
end)

daemon:connect_signal("pause", function ()
    awful.spawn("mpc pause")
end)

daemon:connect_signal("play-pause", function ()
    awful.spawn("mpc toggle")
end)

daemon:connect_signal("next", function ()
    awful.spawn("mpc next")
end)

daemon:connect_signal("previous", function ()
    awful.spawn("mpc prev")
end)

return daemon
