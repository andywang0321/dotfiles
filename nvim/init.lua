-- :source %		sources this file
-- :lua			runs selected lines of lua
-- :lua ...		runs ...

print("Advent of Neovim! Hello my OWN config!")

require("config.lazy") -- `require` is the lua version of python's `import`
-- Neovim only looks for lua files to `require` inside folders with `lua` as their top-level folder.
-- These folders must be in the `runtime_paths` of Neovim (try `:echo nvim_list_runtime_paths()`).

-- who uses a tab character 8 spaces wide for indenting?
vim.opt.shiftwidth = 4

-- keymaps for easy executions
vim.g.mapleader = " "
local map = function(mode, keys, func, desc) vim.keymap.set(mode, keys, func, { desc = desc }) end
map("n", "<leader>term", "<cmd>Floaterm<cr>", "Toggles FloaTerminal")
local oil = require("oil")
map("n", "<leader>oil", function()
	oil.toggle_float()
	require("oil.util").run_after_load(0, oil.open_preview)
end, "Toggles Oil")
map("n", "<leader>ipy", "<cmd>IpyToggle<cr>", "Toggle Ipython")
map("n", "<S-CR>", "<cmd>IpySendLine<cr>", "Send Line to Ipython")
map("v", "<S-CR>", "<Esc><cmd>'<,'>IpySendRange<cr>", "Send Selection to Ipython")

-- nice highlight on yanks
-- see `:help vim.highlight.on_yank()`
-- see `:help vim.api.nvim_create_autocmd()`
-- see `:help vim.api.nvim_create_augroup()`
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking text',
	group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
	callback = function() vim.highlight.on_yank() end,
})
