local ls = require("luasnip")
local types = require("luasnip.util.types")

local s = ls.snippet
local sn = ls.snippet_node

ls.config.set_config({
	history = true, -- Jump back into the last snippet
	updateevents = { "TextChanged", "TextChangedI" },
	autosnippets = true,
	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { " « ", "NonTest" } },
			},
		},
	},
})

vim.keymap.set("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/after/plugin/luasnip.lua<CR>")

--for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/snippets/ft/*.lua", true)) do
--	print("loading", ft_path)
--	loadfile(ft_path)()
--end

--require("luasnip.loaders.from_lua").load({paths = vim.api.nvim_get_runtime_file("lua/snippets/ft", true)})
require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/lua/snippets/ft"})
