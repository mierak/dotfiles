return {
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = {
			"rafamadriz/friendly-snippets",
			"xzbdmw/colorful-menu.nvim",
		},

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
						-- columns = {
						-- 	{ "kind_icon", gap = 1 },
						-- 	{ "label", "label_description", gap = 1 },
						-- 	{ "source_name", gap = 1 },
						-- 	{ "kind" },
						-- },

						-- We don't need label_description now because label and label_description are already
						-- conbined together in label by colorful-menu.nvim.
						--
						-- However, for `basedpyright`, it is recommend to set
						-- columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
						-- because the `label_description` will only be import path.
						columns = {
							{ "kind_icon", "label", gap = 2 },
							{ "kind" },
							{ "source_name", gap = 1 },
						},
						components = {
							label = {
								text = function(ctx)
									return require("colorful-menu").blink_components_text(ctx)
								end,
								highlight = function(ctx)
									return require("colorful-menu").blink_components_highlight(ctx)
								end,
							},
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
	{
		"xzbdmw/colorful-menu.nvim",
		config = function()
			-- You don't need to set these options.
			require("colorful-menu").setup({
				ls = {
					-- If true, try to highlight "not supported" languages.
					fallback = true,
				},
				-- If the built-in logic fails to find a suitable highlight group,
				-- this highlight is applied to the label.
				fallback_highlight = "@variable",
				-- If provided, the plugin truncates the final displayed text to
				-- this width (measured in display cells). Any highlights that extend
				-- beyond the truncation point are ignored. When set to a float
				-- between 0 and 1, it'll be treated as percentage of the width of
				-- the window: math.floor(max_width * vim.api.nvim_win_get_width(0))
				-- Default 60.
				max_width = 60,
			})
		end,
	},
}
