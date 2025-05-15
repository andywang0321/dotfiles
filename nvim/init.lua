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

-- nice highlight on yanks
-- see `:help vim.highlight.on_yank()`
-- see `:help vim.api.nvim_create_autocmd()`
-- see `:help vim.api.nvim_create_augroup()`
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking text',
	group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
	callback = function() vim.highlight.on_yank() end,
})
