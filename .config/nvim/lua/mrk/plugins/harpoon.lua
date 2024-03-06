return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { { "nvim-lua/plenary.nvim" } },
	config = function()
		local harpoon = require("harpoon")
		---@diagnostic disable-next-line: missing-parameter
		harpoon:setup()

		local contents = {}
		local tabline_offset = 0

		local function create_tabline()
			local marks_length = harpoon:list():length()
			if marks_length == 0 then
				vim.o.tabline = ""
				vim.o.showtabline = 0
				return
			end

			contents = {}
			contents[1] = string.rep(" ", tabline_offset)
			local current_file_path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")

			for index = 1, marks_length do
				local harpoon_file_path = harpoon:list():get(index).value
				local file_name = harpoon_file_path == "" and "(empty)" or vim.fn.fnamemodify(harpoon_file_path, ":t")

				if current_file_path == harpoon_file_path then
					contents[index + 1] =
						string.format("%%#HarpoonNumberActive# %s. %%#HarpoonActive#%s ", index, file_name)
				else
					contents[index + 1] =
						string.format("%%#HarpoonNumberInactive# %s. %%#HarpoonInactive#%s ", index, file_name)
				end
			end

			vim.o.showtabline = 2
			vim.o.tabline = table.concat(contents)
		end

        -- stylua: ignore start
        vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() create_tabline() end)
        vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
        vim.keymap.set("n", "<leader>hq", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<leader>hw", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<leader>hf", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<leader>hp", function() harpoon:list():select(4) end)
		-- stylua: ignore end

		vim.api.nvim_set_hl(0, "HarpoonInactive", { fg = "#63698c" })
		vim.api.nvim_set_hl(0, "HarpoonActive", { fg = "white" })
		vim.api.nvim_set_hl(0, "HarpoonNumberActive", { fg = "#7aa2f7" })
		vim.api.nvim_set_hl(0, "HarpoonNumberInactive", { fg = "#7aa2f7" })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufAdd" }, {
			group = vim.api.nvim_create_augroup("harpoon_tabline", { clear = true }),
			callback = function()
				create_tabline()
			end,
		})

		local has_nvimtree, tree = pcall(require, "nvim-tree")
		if has_nvimtree then
			local api = require("nvim-tree.api")

			api.events.subscribe(api.events.Event.Ready, function()
				tabline_offset = tree.config.view.width
				create_tabline()
			end)
			api.events.subscribe(api.events.Event.TreeOpen, function()
				tabline_offset = tree.config.view.width
				create_tabline()
			end)
			api.events.subscribe(api.events.Event.TreeClose, function()
				tabline_offset = 0
				create_tabline()
			end)
		end
	end,
}
