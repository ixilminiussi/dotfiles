return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"leoluz/nvim-dap-go",
	},

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		local wk = require("which-key")
		wk.add({
			{
				"<leader>de",
				dap.terminate,
				desc = "Debug terminate",
				mode = "n",
			},
			{
				"<leader>dt",
				dap.toggle_breakpoint,
				desc = "Debug toggle breakpoint",
				mode = "n",
			},
			{
				"<leader>d<S-t>",
				"<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
				desc = "Debug toggle conditional breakpoint",
				mode = "n",
			},
			{
				"<leader>dc",
				dap.continue,
				desc = "Debug continue",
				mode = "n",
			},
			{
				"<leader>di",
				dap.step_into,
				desc = "Debug step into",
				mode = "n",
			},
			{
				"<leader>do",
				dap.step_over,
				desc = "Debug step over",
				mode = "n",
			},
			{
				"<leader>dw",
				function()
					local variable = vim.fn.input("Expression to watch: ")
					if variable and variable ~= "" then
						dapui.elements.watches.add(variable)
					end
				end,
				desc = "Debug add to watch",
				mode = "n",
			},
		})

		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		dapui.setup()

		-- Cpp, C, Rust config
		dap.adapters.gdb = {
			type = "executable",
			command = "gdb",
			args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
		}

		dap.configurations.cpp = {
			{
				name = "Run executable (GDB)",
				type = "gdb",
				request = "launch",
				-- This requires special handling of 'run_last', see
				-- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
				program = function()
					local path = vim.fn.input({
						prompt = "Path to executable: ",
						default = vim.fn.getcwd() .. "/build/",
						completion = "file",
					})

					return (path and path ~= "") and path or dap.ABORT
				end,
				cwd = "${workspaceFolder}/build", -- Set working directory to build context
			},
			{
				name = "Run executable with arguments (GDB)",
				type = "gdb",
				request = "launch",
				-- This requires special handling of 'run_last', see
				-- https://github.com/mfussenegger/nvim-dap/issues/1025#issuecomment-1695852355
				program = function()
					local path = vim.fn.input({
						prompt = "Path to executable: ",
						default = vim.fn.getcwd() .. "/",
						completion = "file",
					})

					return (path and path ~= "") and path or dap.ABORT
				end,
				args = function()
					local args_str = vim.fn.input({
						prompt = "Arguments: ",
					})
					return vim.split(args_str, " +")
				end,
			},
			{
				name = "Attach to process (GDB)",
				type = "gdb",
				request = "attach",
				processId = require("dap.utils").pick_process,
			},
		}
		--
		-- GO config
		require("dap-go").setup()
	end,
}
