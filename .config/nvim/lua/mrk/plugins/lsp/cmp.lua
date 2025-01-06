return {
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = "rafamadriz/friendly-snippets",

		-- use a release tag to download pre-built binaries
		version = "*",
		-- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
		-- build = 'cargo build --release',
		-- If you use nix, you can build from source using latest nightly rust with:
		-- build = 'nix run .#build-plugin',

		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			-- 'default' for mappings similar to built-in completion
			-- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
			-- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
			-- See the full "keymap" documentation for information on defining your own keymap.
			keymap = { preset = "default" },

			appearance = {
				-- Sets the fallback highlight groups to nvim-cmp's highlight groups
				-- Useful for when your theme doesn't support blink.cmp
				-- Will be removed in a future release
				use_nvim_cmp_as_default = true,
				-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
			},

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			completion = {
				menu = {
					draw = {
						columns = {
							{ "kind_icon", gap = 1 },
							{ "label", "label_description", gap = 1 },
							{ "source_name", gap = 1 },
							{ "kind" },
						},
					},
					border = "rounded",
				},
				accept = {
					create_undo_point = true,
				},

				-- Show documentation when selecting a completion item
				documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "rounded" } },

				-- Display a preview of the selected item on the current line
				ghost_text = { enabled = true },
			},
			signature = { enabled = true, window = { border = "rounded" } },
		},
		opts_extend = { "sources.default" },
	},
	-- {
	-- 	"zbirenbaum/copilot-cmp",
	-- 	dependencies = {
	-- 		"zbirenbaum/copilot.lua",
	-- 	},
	-- 	enabled = false,
	-- 	config = function()
	-- 		require("copilot").setup({
	-- 			suggestion = { enabled = false },
	-- 			panel = { enabled = false },
	-- 			filetypes = {
	-- 				["*"] = true,
	-- 			},
	-- 		})
	-- 		require("copilot_cmp").setup()
	-- 	end,
	-- },
	-- {
	-- 	"yioneko/nvim-cmp",
	-- 	branch = "perf",
	-- 	dependencies = {
	-- 		"hrsh7th/cmp-nvim-lsp",
	-- 		"L3MON4D3/LuaSnip",
	-- 		"hrsh7th/cmp-buffer",
	-- 		"hrsh7th/cmp-path",
	-- 		"hrsh7th/cmp-cmdline",
	-- 		"hrsh7th/cmp-nvim-lua",
	-- 		"hrsh7th/cmp-nvim-lsp-signature-help",
	-- 		"saadparwaiz1/cmp_luasnip",
	-- 	},
	-- 	opts = function()
	-- 		vim.opt.completeopt = { "menu", "menuone", "noselect", "preview" }
	--
	-- 		-- Set up nvim-cmp.
	-- 		local cmp = require("cmp")
	-- 		local cmp_kinds = require("mrk.completion_icons")
	--
	-- 		local cmp_select = { behavior = cmp.SelectBehavior.Select }
	--
	-- 		-- Set configuration for specific filetype.
	-- 		cmp.setup.filetype("gitcommit", {
	-- 			sources = cmp.config.sources({
	-- 				{ name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
	-- 			}, {
	-- 				{ name = "buffer" },
	-- 			}),
	-- 		})
	--
	-- 		-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
	-- 		cmp.setup.cmdline("/", {
	-- 			mapping = cmp.mapping.preset.cmdline(),
	-- 			sources = cmp.config.sources({
	-- 				{ name = "nvim_lsp_document_symbol" },
	-- 			}, {
	-- 				{ name = "buffer", keyword_length = 5 },
	-- 			}),
	-- 		})
	--
	-- 		cmp.setup.cmdline(":", {
	-- 			mapping = cmp.mapping.preset.cmdline(),
	-- 			sources = cmp.config.sources({
	-- 				{ name = "path" },
	-- 			}, {
	-- 				{
	-- 					name = "cmdline",
	-- 					option = {
	-- 						ignore_cmds = { "Man", "!" },
	-- 					},
	-- 				},
	-- 			}),
	-- 		})
	--
	-- 		local border = cmp.config.window.bordered({ scrolloff = 3, border = "single" })
	-- 		-- border.border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
	-- 		-- border.winhighlight = "FloatBorder:FloatBorder,CursorLine:Visual,Search:None"
	--
	-- 		return {
	-- 			formatting = {
	-- 				-- <kind icon> <text> <kind name>
	-- 				fields = { "abbr", "menu", "kind" },
	-- 				format = function(entry, item)
	-- 					local n = entry.source.name
	-- 					if n == "nvim_lsp" then
	-- 						item.menu = "[LSP]"
	-- 					elseif n == "nvim_lua" then
	-- 						item.menu = "[nvim]"
	-- 					else
	-- 						item.menu = string.format("[%s]", n)
	-- 					end
	--
	-- 					item.kind = (cmp_kinds[item.kind] or "") .. "" .. (item.kind or "")
	--
	-- 					-- if maxwidth and #item.abbr > maxwidth then
	-- 					-- 	local last = item.kind == "Snippet" and "~" or ""
	-- 					-- 	item.abbr = string.format("%s %s", string.sub(item.abbr, 1, maxwidth), last)
	-- 					-- end
	--
	-- 					return item
	-- 				end,
	-- 				-- format = function(_, vim_item)
	-- 				-- 	vim_item.menu = vim_item.kind or ""
	-- 				-- 	vim_item.kind = cmp_kinds[vim_item.kind] or ""
	-- 				-- 	return vim_item
	-- 				-- end,
	-- 			},
	-- 			snippet = {
	-- 				expand = function(args)
	-- 					require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
	-- 				end,
	-- 			},
	-- 			window = {
	-- 				completion = border,
	-- 				documentation = border,
	-- 			},
	-- 			mapping = cmp.mapping.preset.insert({
	-- 				["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
	-- 				["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
	-- 				["<C-b>"] = cmp.mapping.scroll_docs(-4),
	-- 				["<C-f>"] = cmp.mapping.scroll_docs(4),
	-- 				["<C-Space>"] = cmp.mapping.complete(),
	-- 				["<C-e>"] = cmp.mapping.abort(),
	-- 				["<C-y>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	-- 			}),
	-- 			sources = cmp.config.sources({
	-- 				{ name = "nvim_lsp_signature_help" },
	-- 				{ name = "nvim_lua" },
	-- 				{ name = "nvim_lsp" },
	-- 				{ name = "buffer", keyword_length = 5 },
	-- 				{ name = "luasnip" }, -- For luasnip users.
	-- 				-- { name = "copilot" },
	-- 			}),
	-- 			experimental = {
	-- 				native_menu = false,
	-- 				ghost_text = true,
	-- 			},
	-- 		}
	-- 	end,
	-- },
}
