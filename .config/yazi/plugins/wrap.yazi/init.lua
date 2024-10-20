local function wrap_scroll(_, args)
	local current = cx.active.current
	local direction = tonumber(args[1])

	if not direction then
		ya.notify({
			title = "Error",
			content = "'" .. args[1] .. "' is not a number",
			timeout = 6.5,
			level = "error",
		})
		return
	end

	local new_cursor = (current.cursor + direction) % #current.files

	new_cursor = (new_cursor + #current.files) % #current.files

	ya.manager_emit("arrow", { new_cursor - current.cursor })
end

return { entry = wrap_scroll }
