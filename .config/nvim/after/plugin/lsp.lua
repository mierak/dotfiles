local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.textDocument.completion.completionItem.snippetSupport = true
--[[ local opts = { noremap=true, silent=true } ]]
--
local cmp_icons = require("mrk.completion_icons")

vim.diagnostic.config({
	float = {
		source = "always",
		border = "solid",
		severity_sort = true,
	},
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "single",
})
vim.lsp.set_log_level("off")
local on_attach = function(_, bufnr)
	vim.keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, { buffer = bufnr, desc = "Go to next diagnostic" })
	vim.keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "Go to prev diagnostic" })
	vim.keymap.set("n", "<leader>dl", "<cmd>Telescope diagnostics<cr>", { buffer = bufnr, desc = "List diagnostics" })
	vim.keymap.set("n", "<leader>do", vim.diagnostic.open_float, { buffer = bufnr, desc = "Open diagnostics in float" })
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = bufnr, desc = "Go to declaration" })
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
	vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover" })
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Go to implementation" })
	vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "go to type definition" })
	vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", { buffer = bufnr, desc = "Find references" })
	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr, desc = "Code actions" })
	vim.keymap.set("n", "<leader><F2>", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename" })
end

local kinds = vim.lsp.protocol.CompletionItemKind
for i, kind in ipairs(kinds) do
	kinds[i] = cmp_icons[kind] or kind
end

require("lspconfig").bashls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require("lspconfig").tsserver.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require("lspconfig").clangd.setup({
	on_attach = on_attach,
	capabilities = capabilities,
})
require("lspconfig").rust_analyzer.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		["rust-analyzer"] = {
			checkOnSave = {
				command = "clippy",
			},
		},
	},
})
require("lspconfig").lua_ls.setup({
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
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
					-- VIM
					"vim",
					"use",
					"require", -- Packer use keyword
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
})
require("lspconfig").jsonls.setup({
	capabilities = capabilities,
})
