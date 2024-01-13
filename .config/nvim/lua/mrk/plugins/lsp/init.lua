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
		"linrongbin16/lsp-progress.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {},
	},
	{
		"neovim/nvim-lspconfig",
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
			servers = {
				bashls = {},
				tsserver = {},
				clangd = {},
				jsonls = {},
				rust_analyzer = {
					["rust_analyze"] = {
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
			local capabilities =
				require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "single",
			})
			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
				vim.lsp.handlers["signature_help"],
				{ border = "single", close_events = { "CursorMoved", "BufHidden" } }
			)
			vim.lsp.set_log_level("off")

			-- Setup keymaps
			local key = vim.keymap.set
            -- stylua: ignore
			local on_attach = function(_, bufnr)
				key("i", "<c-s>", vim.lsp.buf.signature_help)
				key("n", "<leader>dn", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Go to next diagnostic" })
				key("n", "<leader>dp", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Go to prev diagnostic" })
				key("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", { buffer = bufnr, desc = "List diagnostics" })
				key("n", "<leader>do", vim.diagnostic.open_float, { buffer = bufnr, desc = "Open diagnostics in float" })
				key("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
				key("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
				key("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover" })
				key("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to implementation" })
				key("n", "gt", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "go to type definition" })
				key("n", "gr", "<cmd>Telescope lsp_references<cr>", { buffer = bufnr, desc = "Find references" })
				key("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code actions" })
				key("n", "<leader>rs", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename" })
				key("n", "<leader>fs", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", { buffer = bufnr, desc = "Workspace symbols" })
			end

			-- Setup icons
			local kinds = vim.lsp.protocol.CompletionItemKind
			local cmp_icons = require("mrk.completion_icons")
			for i, kind in ipairs(kinds) do
				kinds[i] = cmp_icons[kind] or kind
			end

			-- Setup servers
			for server, config in pairs(opts.servers) do
				require("lspconfig")[server].setup({
					on_attach = on_attach,
					capabilities = capabilities,
					settings = config,
				})
			end

			return {}
		end,
	},
}
