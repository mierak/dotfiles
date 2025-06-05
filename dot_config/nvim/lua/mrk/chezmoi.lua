local prefixes = {
	"after_",
	"before_",
	"create_",
	"empty_",
	"encrypted_",
	"external_",
	"exact_",
	"executable_",
	"literal_",
	"modify_",
	"once_",
	"onchange_",
	"private_",
	"readonly_",
	"remove_",
	"run_",
	"symlink_",
	".tmpl",
}

local function notify(msg, level)
	vim.schedule(function()
		vim.notify(msg, level)
	end)
end

local group = vim.api.nvim_create_augroup("chezmoi", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	pattern = vim.fn.expand("~") .. "/.local/share/chezmoi/*",
	callback = function(event)
		local path = event.match
		for _, prefix in ipairs(prefixes) do
			path = path:gsub(prefix, "")
		end
		path = path:gsub("dot_", ".")
		path = path:gsub(vim.fn.expand("~") .. "/.local/share/chezmoi", vim.fn.expand("~"))

		if not vim.fn.filereadable(path) then
			return
		end

		vim.system({ "chezmoi", "apply", path }, {}, function(result)
			if result.code ~= 0 then
				notify("chezmoi apply failed: " .. result.stderr, vim.log.levels.ERROR)
			else
				notify("chezmoi apply succes", vim.log.levels.INFO)
			end
		end)
	end,
})
