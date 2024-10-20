local shell = os.getenv("SHELL")

local function error(s, ...)
  ya.notify({ title = "fuse-archive", content = string.format(s, ...), timeout = 3, level = "error" })
end

local set_state = ya.sync(function(state, archive, key, value)
  if state[archive] then
    state[archive][key] = value
  else
    state[archive] = {}
    state[archive][key] = value
  end
end)

local get_state = ya.sync(function(state, archive, key)
  if state[archive] then
    return state[archive][key]
  else
    return nil
  end
end)

local is_mount_point = ya.sync(function(state)
  local dir = cx.active.current.cwd:name()
  for archive, _ in pairs(state) do
    if archive == dir then
      return true
    end
  end
  return false
end)

local current_file = ya.sync(function()
  local h = cx.active.current.hovered
  if h then
    return h.name
  else
    return nil
  end
end)

local current_dir = ya.sync(function()
  return tostring(cx.active.current.cwd)
end)

local current_dir_name = ya.sync(function()
  return cx.active.current.cwd:name()
end)

local enter = ya.sync(function()
  local h = cx.active.current.hovered
  if h then
    if h.cha.is_dir then
		  ya.manager_emit("enter", {})
    else
      if get_state("global", "smart_enter") then
        ya.manager_emit("open", { hovered = true })
      else
        ya.manager_emit("enter", {})
      end
    end
  end
end)

local function run_command(cmd, args)
  local cwd = current_dir()
  local child, cmd_err = Command(cmd)
    :args(args)
    :cwd(cwd)
    :stdin(Command.INHERIT)
    :stdout(Command.PIPED)
    :stderr(Command.INHERIT)
    :spawn()

  if not child then
    error("Spawn `fuse-archive` failed with error code %s", cmd_err)
    return cmd_err
  end

  local output, out_err = child:wait_with_output()
  if not output then
    error("Cannot read `fuse-archive` output, error code %s", out_err)
    return out_err
  elseif not output.status.success then
    error("`fuse-archive` exited with error code %s", output.status.code)
    return output.status.code
  else
    return 0
  end
end

local valid_extension = ya.sync(function()
  local h = cx.active.current.hovered
  if h then
    if h.cha.is_dir then
      return false
    end
    local valid_extensions = {
      "zip", "gz", "bz2", "tar", "tgz", "tbz2", "txz", "xz", "tzs",
      "zst", "iso", "rar", "7z", "cpio", "lz", "lzma", "shar", "a",
      "ar", "apk", "jar", "xpi", "cab"
    }
    local filename = tostring(h.url)
    for _, ext in ipairs(valid_extensions) do
      if filename:find("%." .. ext .. "$") then
        return true
      end
    end
    return false
  else
    return false
  end
end)

local function fuse_dir()
  local state_dir = os.getenv("XDG_STATE_HOME")
  if not state_dir then
    local home = os.getenv("HOME")
    if not home then
      state_dir = "/tmp"
    else
      state_dir = home .. "/" .. ".local/state"
    end
  end
  return state_dir .. "/yazi/fuse-archive"
end

local function get_tmp_file_name(path)
  local time_now = os.time()
  local hex_time = string.format("%x", time_now)
  return path .. ".tmp" .. hex_time
end

local function create_mount_path(file)
  local tmp_path = get_state("global", "fuse_dir") .. "/" .. file

  local ret_code = run_command("mkdir", { "-p", tmp_path })
  if ret_code ~= 0 then
    error("Cannot create tmp file %s", tmp_path)
    return nil
  end
  return tmp_path
end

local function setup(_, opts)
  local fuse = fuse_dir()
  set_state("global", "fuse_dir", fuse)
  if opts and opts.smart_enter then
    set_state("global", "smart_enter", true)
  else
    set_state("global", "smart_enter", false)
  end
end

return {
  entry = function(_, args)
    local action = args[1]
    if not action then
      return
    end

    if action == "mount" then
      local file = current_file()
      if file == nil then
        return
      end
      if not valid_extension() then
        enter()
        return
      end
      local tmp_file_name = get_tmp_file_name(file)
      local tmp_file_path = create_mount_path(tmp_file_name)
      if not tmp_file_path then
        return
      end
      local ret_code = run_command(shell, { "-c", "fuse-archive " .. ya.quote(file) .." " .. ya.quote(tmp_file_path) })
      if ret_code ~= 0 then
        os.remove(tmp_file_path)
        error(" Unable to mount %s", file)
        return
      end
      set_state(tmp_file_name, "cwd", current_dir())
      set_state(tmp_file_name, "tmp", tmp_file_path)
      ya.manager_emit("cd", { tmp_file_path })
      ya.manager_emit("enter", {})
    end

    if action == "unmount" then
      if not is_mount_point() then
        ya.manager_emit("leave", {})
        return
      end
      local file = current_dir_name()
      local tmp_file = get_state(file, "tmp")
      ya.manager_emit("cd", { get_state(file, "cwd") })

      local ret_code = run_command(shell, { "-c", "fusermount -u " .. ya.quote(tmp_file) })
      if ret_code ~= 0 then
        error("Unable to unmount %s", tmp_file)
      end

      local deleted, _ = os.remove(tmp_file)
      if not deleted then
        error("Cannot delete tmp file %s", tmp_file)
      end
      return
    end
  end,
  setup = setup,
}
