return {
	{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"theHamsta/nvim-dap-virtual-text",
		},
		opts = {},
		config = function(_, opts)
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup(opts)
			local debug_win = nil
			local debug_tab = nil
			local debug_tabnr = nil

			local function open_in_tab()
				if debug_win and vim.api.nvim_win_is_valid(debug_win) then
					vim.api.nvim_set_current_win(debug_win)
					return
				end

				vim.cmd("tabedit %")
				debug_win = vim.fn.win_getid()
				debug_tab = vim.api.nvim_win_get_tabpage(debug_win)
				debug_tabnr = vim.api.nvim_tabpage_get_number(debug_tab)

				dapui.open()
			end

			local function close_tab()
				dapui.close()

				if debug_tab and vim.api.nvim_tabpage_is_valid(debug_tab) then
					vim.api.nvim_exec("tabclose " .. debug_tabnr, false)
				end

				debug_win = nil
				debug_tab = nil
				debug_tabnr = nil
			end

			-- Attach DAP UI to DAP events
			dap.listeners.after.event_initialized["dapui_config"] = function()
				open_in_tab()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				close_tab()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				close_tab()
			end

			local function eval_input()
				local expr = nil
				vim.ui.input({ prompt = "Evaluate: " }, function(result)
					expr = result
				end)
				dapui.eval(expr)
			end

			local function breakpoint_with_condition()
				require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end

			local key = vim.keymap.set
			key("n", "<leader>dB", breakpoint_with_condition, { desc = "Breakpoint Condition" })
			key("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })
			key("n", "<leader>dB", dap.set_breakpoint, { desc = "Toggle breakpoint" })
			key("n", "<leader>dc", dap.continue, { desc = "Continue" })
			key("n", "<leader>dC", dap.run_to_cursor, { desc = "Debug to cursor" })
			key("n", "<leader>di", dap.step_into, { desc = "Step into" })
			key("n", "<leader>do", dap.step_over, { desc = "Step over" })
			key("n", "<leader>dO", dap.step_out, { desc = "Step out" })
			key("n", "<leader>dr", dap.repl.toggle, { desc = "Toggle REPL" })
			key("n", "<leader>dj", dap.down, { desc = "Down" })
			key("n", "<leader>dk", dap.up, { desc = "Up" })
			key("v", "<leader>de", dapui.eval, { desc = "Evaluate expression" })
			key("n", "<leader>de", eval_input, { desc = "Evaluate expression" })

			dap.adapters.lldb = {
				type = "executable",
				command = "/usr/bin/lldb-vscode",
				name = "lldb",
			}
			dap.adapters.rust = dap.adapters.lldb
			dap.configurations.rust = {
				{
					name = "Launch",
					type = "lldb",
					request = "launch",
					sourceLanguages = { "rust" },
					program = function()
						local metadata_json = vim.fn.system("cargo metadata --format-version 1 --no-deps")
						local metadata = vim.fn.json_decode(metadata_json)
						local target_name = metadata.packages[1].targets[1].name
						local target_dir = metadata.target_directory
						return target_dir .. "/debug/" .. target_name
					end,
				},
				{
					name = "Attach to process",
					type = "lldb",
					request = "attach",
					pid = require("dap.utils").pick_process,
				},
			}
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		opts = {},
	},
}
