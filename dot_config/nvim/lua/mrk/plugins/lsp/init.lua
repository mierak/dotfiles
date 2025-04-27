local function getKeyMapper(event)
	return function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
	end
end

return {
	{
		require("mrk/plugins/lsp/cmp"),
	},
	-- {
	-- 	require("mrk/plugins/lsp/dap"),
	-- },
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {
			tsserver_max_memory = "8192",
		},
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = os.getenv("HOME") .. "/.local/share/nvim/lazy" },
			},
		},
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^5",
		lazy = false,
		ft = "rust",
		init = function()
			if not os.execute("pgrep ra-multiplex") then
				os.execute("ra-multiplex server &")
			end
			vim.g.rustaceanvim = {
				tools = {
					float_win_config = {
						border = "single",
					},
					code_actions = {
						ui_select_fallback = false,
					},
				},
				server = {
					default_settings = {
						["rust-analyzer"] = {},
					},
				},
			}

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("rustaceanvim-lsp-attach", { clear = true }),
				callback = function(event)
					if not vim.endswith(event.file, ".rs") then
						return
					end
					local key = getKeyMapper(event)
                    -- stylua: ignore start
                    -- key("<leader>dn",   function() vim.cmd.RustLsp { 'crateGraph', 'x11', '[output]' } end,                           "Go to next diagnostic" )
                    key("<leader>ca",   function() vim.cmd.RustLsp('codeAction') end,  "Code Actions" )
                    key("<leader>do",   function() vim.cmd.RustLsp({ 'renderDiagnostic', 'current' }) end,  "Open diagnostics" )
                    key("<leader>od",   function() vim.cmd.RustLsp('openDocs') end,  "Open docs" )
                    key("J",   function() vim.cmd.RustLsp('joinLines') end,  "join lines" )
					-- stylua: ignore end
				end,
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
			{ "williamboman/mason.nvim", opts = {} },
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
			ensure_installed = { "stylua", "shfmt", "shellcheck", "typescript-language-server" },
			servers = {
				bashls = {},
				clangd = {},
				jsonls = {},
				yamlls = {},
				helm_ls = {},
				["tailwindcss-language-server"] = {},
				["css-lsp"] = {},
				["astro-language-server"] = {},
				-- eslint = {},
				-- rust_analyzer = {},
				lua_ls = {
					settings = {
						Lua = {
							runtime = {
								pathStrict = true,
							},
							workspace = {
								library = {
									vim.api.nvim_get_runtime_file("", true),
								},
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
			vim.o.winborder = "single"
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "single", source = "if_many" },
				virtual_text = { current_line = false },
				signs = {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",
						[vim.diagnostic.severity.HINT] = "󰌶 ",
					},
				},
			})
			vim.lsp.set_log_level("off")

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("custom-lsp-attach", { clear = true }),
				callback = function(event)
					local key = getKeyMapper(event)

                    -- stylua: ignore start
                    key("<leader>dn",   function() vim.diagnostic.jump({ count = 1, float = true }) end,  "Go to next diagnostic" )
                    key("<leader>dp",   function() vim.diagnostic.jump({ count = -1, float = true }) end, "Go to prev diagnostic" )
                    key("<leader>do",   vim.diagnostic.open_float,                                        "Open diagnostics in float" )
                    key("gD",           vim.lsp.buf.declaration,                                          "Go to declaration" )
                    key("K",            vim.lsp.buf.hover,                                                "Hover" )
                    key("gt",           vim.lsp.buf.type_definition,                                      "Go to type definition" )
                    key("<leader>ca",   vim.lsp.buf.code_action,                                          "Code actions" )
                    key("<leader>rs",   vim.lsp.buf.rename,                                               "Rename" )
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

			local capabilities = require("blink.cmp").get_lsp_capabilities()

			local ensure_installed = vim.iter(vim.tbl_keys(opts.servers)):totable()
			vim.list_extend(ensure_installed, opts.ensure_installed)

			require("mason-tool-installer").setup({
				ensure_installed = ensure_installed,
				auto_update = true,
				debounce_hourse = 24,
			})

			require("mason-lspconfig").setup({
				ensure_installed = {},
				automatic_installation = false,
				handlers = {
					function(server_name)
						local server = opts.servers[server_name] or {}
						server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
						require("lspconfig")[server_name].setup(server)
					end,
				},
			})
		end,
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
}
