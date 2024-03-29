local function open_nvim_tree(data)
	-- buffer is a directory
	local directory = vim.fn.isdirectory(data.file) == 1
	if not directory then
		return
	end

	-- create a new, empty buffer
	vim.cmd.enew()
	-- wipe the directory buffer
	vim.cmd.bw(data.buf)
	-- change to the directory
	vim.cmd.cd(data.file)
	-- open the tree
	require("nvim-tree.api").tree.open()
end

return {
	"nvim-tree/nvim-tree.lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	opts = function()
		-- Open NvimTree if startup buffer is directory
		vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
		return {

			disable_netrw = true,
			open_on_tab = false,
			hijack_cursor = true,
			diagnostics = {
				enable = true,
				show_on_dirs = true,
				show_on_open_dirs = true,
			},
			filters = {
				custom = { "^.git$", "^.github$", "^node_modules" },
			},
			git = {
				enable = true,
				show_on_dirs = true,
				show_on_open_dirs = true,
			},
			modified = {
				enable = true,
				show_on_dirs = true,
				show_on_open_dirs = true,
			},
			update_focused_file = {
				enable = true,
				update_root = false,
				update_cwd = false,
				ignore_list = {},
			},
			renderer = {
				indent_markers = { enable = true },
			},
			view = {
				width = 35,
			},
		}
	end,
}
