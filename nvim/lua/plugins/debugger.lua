return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "mfussenegger/nvim-dap-python",
        "rcarriga/nvim-dap-ui",
        "theHamsta/nvim-dap-virtual-text",
        "nvim-neotest/nvim-nio",
        "williamboman/mason.nvim",
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        local dap_python = require("dap-python")

        dapui.setup()
        dap_python.setup("/Users/andywang/devenv/bin/python")
        require("nvim-dap-virtual-text").setup({})

        dap.listeners.before.attach.dapui_config = function()
            dapui.open()
        end
        dap.listeners.before.launch.dapui_config = function()
            dapui.open()
        end
        --	dap.listeners.before.event_terminated.dapui_config = function()
        --		dapui.close()
        --	end
        --	dap.listeners.before.event_exited.dapui_config = function()
        --		dapui.close()
        --	end

        vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "[D]ebug [B]reakpoint" })
        vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "[D]bug [C]ontinue" })
        vim.keymap.set("n", "<leader>d1", dap.step_into, { desc = "[D]bug [1] (step into)" })
        vim.keymap.set("n", "<leader>d2", dap.step_over, { desc = "[D]bug [2] (step over)" })
        vim.keymap.set("n", "<leader>d3", dap.step_out, { desc = "[D]bug [3] (step_out) " })
        vim.keymap.set("n", "<leader>d4", dap.step_back, { desc = "[D]bug [4] (step back)" })
        vim.keymap.set("n", "<leader>d5", dap.restart, { desc = "[D]bug [5] (restart)" })
        vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "[D]bug [Q]uit" })
        vim.keymap.set("n", "<leader>dt", dapui.toggle, { desc = "[D]bugger [T]oggle" })

        vim.fn.sign_define("DapBreakpoint", {
            text = "🔴", -- "🤯", "",
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
            text = "👉", -- or "", -- or "➡️", -- or "→"
            texthl = "DiagnosticSignWarn",
            linehl = "Visual",
            numhl = "DiagnosticSignWarn",
        })
    end,
}
