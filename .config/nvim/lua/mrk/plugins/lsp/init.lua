return {
	{
		require("mrk/plugins/lsp/cmp"),
	},
	{
		require("mrk/plugins/lsp/dap"),
	},
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {
			tsserver_max_memory = "8192",
		},
	},
	{
		"felpafel/inlay-hint.nvim",
		event = "LspAttach",
		config = true,
		opts = {
			-- Position of virtual text. Possible values:
			-- 'eol': right after eol character (default).
			-- 'right_align': display right aligned in the window.
			-- 'inline': display at the specified column, and shift the buffer
			-- text to the right as needed.
			virt_text_pos = "eol",
			-- Can be supplied either as a string or as an integer,
			-- the latter which can be obtained using |nvim_get_hl_id_by_name()|.
			highlight_group = "LspInlayHint",
			-- Control how highlights are combined with the
			-- highlights of the text.
			-- 'combine': combine with background text color. (default)
			-- 'replace': only show the virt_text color.
			hl_mode = "combine",
			-- line_hints: array with all hints present in current line.
			-- options: table with this plugin configuration.
			-- bufnr: buffer id from where the hints come from.
			display_callback = function(line_hints, options, bufnr)
				if options.virt_text_pos == "inline" then
					local lhint = {}
					for _, hint in pairs(line_hints) do
						local text = ""
						local label = hint.label
						if type(label) == "string" then
							text = label
						else
							for _, part in ipairs(label) do
								text = text .. part.value
							end
						end
						if hint.paddingLeft then
							text = " " .. text
						end
						if hint.paddingRight then
							text = text .. " "
						end
						lhint[#lhint + 1] = { text = text, col = hint.position.character }
					end
					return lhint
				elseif options.virt_text_pos == "eol" or options.virt_text_pos == "right_align" then
					local k1 = {}
					local k2 = {}
					table.sort(line_hints, function(a, b)
						return a.position.character < b.position.character
					end)
					for _, hint in pairs(line_hints) do
						local label = hint.label
						local kind = hint.kind
						local text = ""
						if type(label) == "string" then
							text = label
						else
							for _, part in ipairs(label) do
								text = text .. part.value
							end
						end
						if kind == 1 then
							k1[#k1 + 1] = text:gsub("^:%s*", "")
						else
							k2[#k2 + 1] = text:gsub(":$", "")
						end
					end
					local text = ""
					if #k2 > 0 then
						text = "<- (" .. table.concat(k2, ",") .. ")"
					end
					if #text > 0 then
						text = text .. " "
					end
					if #k1 > 0 then
						text = text .. "=> " .. table.concat(k1, ",")
					end

					return text
				end
				return nil
			end,
		},
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
	-- "folke/neodev.nvim",
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			-- "hrsh7th/cmp-nvim-lsp",
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
			ensure_installed = { "stylua", "shfmt", "shellcheck" },
			servers = {
				bashls = {},
				ts_ls = {},
				clangd = {},
				jsonls = {},
				yamlls = {},
				helm_ls = {},
				["tailwindcss-language-server"] = {},
				["css-lsp"] = {},
				["astro-language-server"] = {},
				["termux-language-server"] = {},
				-- eslint = {},
				rust_analyzer = {
					settings = {
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
				},
				lua_ls = {
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
		},
		config = function(_, opts)
			-- require("neodev").setup({})

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "single",
			})

			vim.diagnostic.config({ float = { border = "single" } })
			vim.lsp.set_log_level("off")

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local telescope = require("telescope.builtin")
					local key = function(keys, func, desc)
						vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end
                    -- key("i", "<c-s>", vim.lsp.buf.signature_help)
                    -- stylua: ignore start
                    key("<leader>dn",   vim.diagnostic.goto_next,                           "Go to next diagnostic" )
                    key("<leader>dp",   vim.diagnostic.goto_prev,                           "Go to prev diagnostic" )
                    key("<leader>dl",   telescope.diagnostics,                              "List diagnostics" )
                    key("<leader>do",   vim.diagnostic.open_float,                          "Open diagnostics in float" )
                    key("gD",           vim.lsp.buf.declaration,                            "Go to declaration" )
                    key("gd",           telescope.lsp_definitions,                          "Go to definition" )
                    key("K",            vim.lsp.buf.hover,                                  "Hover" )
                    key("gi",           telescope.lsp_implementations,                      "Go to implementation" )
                    key("gt",           vim.lsp.buf.type_definition,                        "Go to type definition" )
                    key("gr",           telescope.lsp_references,                           "Find references" )
                    key("<leader>ca",   vim.lsp.buf.code_action,                            "Code actions" )
                    key("<leader>rs",   vim.lsp.buf.rename,                                 "Rename" )
                    key("<leader>fs",   telescope.lsp_dynamic_workspace_symbols,            "Workspace symbols" )
					-- stylua: ignore end

					local client = vim.lsp.get_client_by_id(event.data.client_id)

					if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
						vim.lsp.inlay_hint.enable(true)
						key("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({}))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			-- capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

			require("mason").setup()

			-- TODO remove this when the issue with RA is solved
			for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
				local default_diagnostic_handler = vim.lsp.handlers[method]
				vim.lsp.handlers[method] = function(err, result, context, config)
					if err ~= nil and err.code == -32802 then
						return
					end
					return default_diagnostic_handler(err, result, context, config)
				end
			end
			local toinstall = vim.iter(vim.tbl_keys(opts.servers)):totable()
			vim.list_extend(toinstall, opts.ensure_installed)

			require("mason-tool-installer").setup({
				ensure_installed = toinstall,
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
