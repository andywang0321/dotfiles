return {
	"mfussenegger/nvim-dap",
	enabled = false,
	dependencies = {
		{
			"igorlfs/nvim-dap-view",
			opts = {
				winbar = {
					controls = { enabled = true, },
					sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
					default_section = "scopes",
					headers = {
						breakpoints = "[B]kpts",
						scopes = "[S]copes",
						exceptions = "[E]xcp",
						watches = "[W]atches",
						threads = "[T]hreads",
						repl = "[R]EPL",
						console = "[C]onsole",
					},
				},
				windows = {
					position = "below",
				},
			}
		},
		"mfussenegger/nvim-dap-python",
		"theHamsta/nvim-dap-virtual-text",
		--"rcarriga/nvim-dap-ui",
		--"nvim-neotest/nvim-nio",
	},
	config = function()
		local dap = require("dap")
		local dap_python = require("dap-python")
		local dap_view = require("dap-view")
		--local dapui = require("dapui")

		--dapui.setup()
		dap_python.setup("uv")
		table.insert(require('dap').configurations.python, {
			type = 'python',
			request = 'launch',
			name = 'Run file in Nvim root directory',
			program = '${file}',
			cwd = vim.fn.getcwd()
			-- ... more options, see https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
		})
		require("nvim-dap-virtual-text").setup()

		dap.listeners.before.attach.dap_view_config = function() dap_view.open() end
		dap.listeners.before.launch.dap_view_config = function() dap_view.open() end
		dap.listeners.before.event_terminated.dap_view_config = function()
			print("Debug session terminated!")
			dap_view.jump_to_view("console")
			vim.defer_fn(dap_view.close, 1500)
		end
		dap.listeners.before.event_exited.dap_view_config = function()
			print("Terminated!")
			dap_view.jump_to_view("console")
			vim.defer_fn(dap_view.close, 1500)
		end

		--dap.listeners.before.attach.dapui_config = function() dapui.open() end
		--dap.listeners.before.launch.dapui_config = function() dapui.open() end
		--dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
		--dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

		local map = function(keys, func, desc) vim.keymap.set("n", keys, func, { desc = "Debug: " .. desc }) end
		map("<Leader>db", dap.toggle_breakpoint, "Toggle breakpoint")
		map("<Leader>dB", function() dap.set_breakpoint(vim.fn.input("Breakpoint Condition: ")) end, "Conditional Breakpoint")
		map("<leader>dc", dap.continue, "Continue")
		map("<C-A-l>", dap.step_into, "Step into")
		map("<C-A-j>", dap.step_over, "Step over)")
		map("<C-A-h>", dap.step_out, "Step out")
		map("<C-A-k>", dap.step_back, "Step back")
		map("<leader>dr", dap.restart, "Restart")
		map("<leader>dq", dap.terminate, "Quit")
		map("<leader>dt", dap_view.toggle, "Toggle UI")
		--map("<leader>dt", dapui.toggle, "Toggle UI")

		vim.fn.sign_define("DapBreakpoint", {
			text = "🔴", -- "🤯", "",
			texthl = "DiagnosticSignError",
			linehl = "",
			numhl = "",
		})

		vim.fn.sign_define("DapBreakpointCondition", {
			text = "🔵", -- "🤯", "",
			texthl = "DiagnosticSignError",
			linehl = "",
			numhl = "",
		})

		vim.fn.sign_define("DapBreakpointRejected", {
			text = "❌", -- or ""
			texthl = "DiagnosticSignError",
			linehl = "",
			numhl = "",
		})

		vim.fn.sign_define("DapStopped", {
			text = "🚀", -- or "", -- or "➡️", -- or "→"
			texthl = "DiagnosticSignWarn",
			linehl = "Visual",
			numhl = "DiagnosticSignWarn",
		})
	end,
}
