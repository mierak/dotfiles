return {
	"L3MON4D3/LuaSnip",
	opts = function()
		local ls = require("luasnip")
		local types = require("luasnip.util.types")

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

		--for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/snippets/ft/*.lua", true)) do
		--	print("loading", ft_path)
		--	loadfile(ft_path)()
		--end

		--require("luasnip.loaders.from_lua").load({paths = vim.api.nvim_get_runtime_file("lua/snippets/ft", true)})
		require("luasnip").config.setup({ store_selection_keys = "<C-t>" })
		-- require("luasnip.loaders.from_lua").load({ paths = "~/.config/nvim/lua/mrk/snippets/ft" })
		return {}
	end,
}
