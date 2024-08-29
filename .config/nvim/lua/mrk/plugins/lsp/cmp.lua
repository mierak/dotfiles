return {
	{
		"zbirenbaum/copilot-cmp",
		dependencies = {
			"zbirenbaum/copilot.lua",
		},
		enabled = false,
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
				filetypes = {
					["*"] = true,
				},
			})
			require("copilot_cmp").setup()
		end,
	},
	{
		"yioneko/nvim-cmp",
		branch = "perf",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-nvim-lsp-signature-help",
			"saadparwaiz1/cmp_luasnip",
		},
		opts = function()
			vim.opt.completeopt = { "menu", "menuone", "noselect", "preview" }

			-- Set up nvim-cmp.
			local cmp = require("cmp")
			local cmp_kinds = require("mrk.completion_icons")

			local cmp_select = { behavior = cmp.SelectBehavior.Select }

			-- Set configuration for specific filetype.
			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources({
					{ name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
				}, {
					{ name = "buffer" },
				}),
			})

			-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "nvim_lsp_document_symbol" },
				}, {
					{ name = "buffer", keyword_length = 5 },
				}),
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{
						name = "cmdline",
						option = {
							ignore_cmds = { "Man", "!" },
						},
					},
				}),
			})

			return {
				formatting = {
					-- <kind icon> <text> <kind name>
					fields = { "abbr", "menu", "kind" },
					format = function(entry, item)
						local n = entry.source.name
						if n == "nvim_lsp" then
							item.menu = "[LSP]"
						elseif n == "nvim_lua" then
							item.menu = "[nvim]"
						else
							item.menu = string.format("[%s]", n)
						end

						item.kind = (cmp_kinds[item.kind] or "") .. "" .. (item.kind or "")

						-- if maxwidth and #item.abbr > maxwidth then
						-- 	local last = item.kind == "Snippet" and "~" or ""
						-- 	item.abbr = string.format("%s %s", string.sub(item.abbr, 1, maxwidth), last)
						-- end

						return item
					end,
					-- format = function(_, vim_item)
					-- 	vim_item.menu = vim_item.kind or ""
					-- 	vim_item.kind = cmp_kinds[vim_item.kind] or ""
					-- 	return vim_item
					-- end,
				},
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
				window = {
					completion = cmp.config.window.bordered({ scrolloff = 3, border = "single" }),
					documentation = cmp.config.window.bordered({ scrolloff = 3, border = "single" }),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
					["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp_signature_help" },
					{ name = "nvim_lua" },
					{ name = "nvim_lsp" },
					{ name = "buffer", keyword_length = 5 },
					{ name = "luasnip" }, -- For luasnip users.
					-- { name = "copilot" },
				}),
				experimental = {
					native_menu = false,
					ghost_text = true,
				},
			}
		end,
	},
}
