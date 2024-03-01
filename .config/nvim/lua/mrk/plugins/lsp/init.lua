return {
	{
		require("mrk/plugins/lsp/luasnip"),
	},
	{
		require("mrk/plugins/lsp/cmp"),
	},
	{
		require("mrk/plugins/lsp/dap"),
	},
	{
		"glepnir/lspsaga.nvim",
		event = "LspAttach",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			lightbulb = { enable = false },
		},
	},

	"folke/neodev.nvim",
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		opts = {
			autoformat = false,
			inlay_hints = { enabled = true },
			diagnostics = {
				float = {
					source = "always",
					border = "solid",
					severity_sort = true,
				},
			},
			ensure_installed = { "stylua", "prettier", "shfmt", "shellcheck" },
			servers = {
				bashls = {},
				tsserver = {},
				clangd = {},
				jsonls = {},
				yamlls = {},
				helm_ls = {},
				eslint = {},
				rust_analyzer = {
					["rust-analyzer"] = {
						cargo = {
							features = "all",
						},
						checkOnSave = {
							command = "clippy",
						},
						procMacro = {
							enable = true,
							attributes = {
								enable = true,
							},
						},
					},
				},
				lua_ls = {
					Lua = {
						runtime = {
							pathStrict = true,
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						diagnostics = {
							enable = true,
							globals = {
								"vim",
								"use",
								"require",
							},
						},
						completion = {
							displayContext = 10,
						},
						hint = {
							enable = true,
						},
					},
				},
			},
		},
		config = function(_, opts)
			require("neodev").setup({})

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "single",
			})
			vim.lsp.set_log_level("off")

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local key = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
                    -- key("i", "<c-s>", vim.lsp.buf.signature_help)
                    -- stylua: ignore start
                    key("<leader>dn",   vim.diagnostic.goto_next,                           "Go to next diagnostic" )
                    key("<leader>dp",   vim.diagnostic.goto_prev,                           "Go to prev diagnostic" )
                    key("<leader>dl",   "<cmd>Telescope diagnostics<cr>",                   "List diagnostics" )
                    key("<leader>do",   vim.diagnostic.open_float,                          "Open diagnostics in float" )
                    key("gD",           vim.lsp.buf.declaration,                            "Go to declaration" )
                    key("gd",           vim.lsp.buf.definition,                             "Go to definition" )
                    key("K",            vim.lsp.buf.hover,                                  "Hover" )
                    key("gi",           vim.lsp.buf.implementation,                         "Go to implementation" )
                    key("gt",           vim.lsp.buf.type_definition,                        "Go to type definition" )
                    key("gr",           "<cmd>Telescope lsp_references<cr>",                "Find references" )
                    key("<leader>ca",   vim.lsp.buf.code_action,                            "Code actions" )
                    key("<leader>rs",   vim.lsp.buf.rename,                                 "Rename" )
                    key("<leader>fs",   "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", "Workspace symbols" )
					-- stylua: ignore end

					-- Highlight references after a short delay of cursor being on top of the word
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client.server_capabilities.documentHighlightProvider then
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							callback = vim.lsp.buf.clear_references,
						})
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			require("mason").setup()
			require("mason-tool-installer").setup({
				ensure_installed = vim.list_extend(vim.tbl_keys(opts.servers), opts.ensure_installed),
				auto_update = true,
				debounce_hourse = 24,
			})
			require("mason-lspconfig").setup({
				handlers = {
					function(server_name)
						local server = opts.servers[server_name] or {}
						-- This handles overriding only values explicitly passed
						-- by the server configuration above. Useful when disabling
						-- certain features of an LSP (for example, turning off formatting for tsserver)
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
	},
}
