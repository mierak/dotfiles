local trouble = require("trouble.providers.telescope")

return {
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	{
		"nvim-telescope/telescope-ui-select.nvim",
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		config = function(_, opts)
			local telescope = require("telescope")

			telescope.setup(opts)

			telescope.load_extension("ui-select")
			telescope.load_extension("fzf")
			telescope.load_extension("harpoon")
		end,
		opts = function()
			return {
				defaults = {
					path_display = { "smart" },
					sorting_strategy = "ascending",
					layout_config = {
						width = 0.90,
						height = 0.95,
						horizontal = {
							prompt_position = "top",
							preview_cutoff = 60,
							preview_width = 0.7,
						},
					},
					mappings = {
						i = { ["<c-t>"] = trouble.open_with_trouble },
						n = { ["<c-t>"] = trouble.open_with_trouble },
					},
				},
				pickers = {
					find_files = {
						--find_command = { "fd", "--strip-cwd-prefix", "--type", "f" },
					},
				},
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({
							layout_config = {
								prompt_position = "top",
								width = 0.4,
								height = 0.4,
							},
							border = {},
							previewer = false,
							shorten_path = false,
						}),
					},
					fzf = {
						fuzzy = true, -- false will only do exact matching
						override_generic_sorter = true, -- override the generic sorter
						override_file_sorter = true, -- override the file sorter
						case_mode = "smart_case", -- or "ignore_case" or "respect_case"
						-- the default case_mode is "smart_case"
					},
				},
			}
		end,
	},
}
