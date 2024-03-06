return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { { "nvim-lua/plenary.nvim" } },
	config = function()
		local harpoon = require("harpoon")
		---@diagnostic disable-next-line: missing-parameter
		harpoon:setup()

		local function create_tabline()
			local contents = {}
			-- TODO hook to nvim tree
			contents[1] = string.rep(" ", 35)
			local marks_length = harpoon:list():length()
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

		vim.o.showtabline = 2

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
	end,
}
