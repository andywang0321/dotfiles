-- :source %		sources this file
-- :lua			runs selected lines of lua
-- :lua ...		runs ...

print("Advent of Neovim! Hello my OWN config!")

require("config.lazy") -- `require` is the lua version of python's `import`
-- Neovim only looks for lua files to `require` inside folders with `lua` as their top-level folder.
-- These folders must be in the `runtime_paths` of Neovim (try `:echo nvim_list_runtime_paths()`).

-- who uses a tab character 8 spaces wide for indenting?
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.smarttab = true
vim.opt.shiftwidth = 4
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 5
vim.opt.cursorline = true
vim.opt.cursorlineopt = "number"
vim.opt.linebreak = true

-- keymaps for easy executions
vim.g.mapleader = " "
local map = function(mode, keys, func, desc) vim.keymap.set(mode, keys, func, { desc = desc }) end

-- FloaTerminal
map("n", "<leader>term", "<cmd>Floaterm<cr>", "Toggles FloaTerminal")

-- Oil + Preview = Nice file explorer
local oil = require("oil")
map("n", "<leader><leader>", function()
  oil.toggle_float()
  require("oil.util").run_after_load(0, oil.open_preview)
end, "Toggles Oil")

-- Interactive Neovim Terminal iPython
-- map("n", "<leader>ip", "<cmd>IpyToggle<cr>", "Toggle Ipython")
-- map("n", "<S-CR>", "<cmd>IpySendLine<cr>", "Send Line to Ipython")
-- map("v", "<S-CR>", "<Esc><cmd>'<,'>IpySendRange<cr>", "Send Selection to Ipython")

-- Interactive Wezterm iPython
map("n", "<leader>ip", "<cmd>WeztermIpythonToggle<cr>", "Toggle Wezterm iPython pane")
map({ "n", "i" }, "<S-CR>", "<cmd>WeztermIpythonSendLine<cr>", "Send Line to Wezterm iPython pane")
map("x", "<S-CR>", "<cmd>WeztermIpythonSendRange<cr>", "Send Selection to Wezterm iPython pane")

-- Obsidian workflow
map('n', '<leader>ot', ':ObsidianTemplate note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>', "Insert Note Template")
map('n', '<leader>ok', ":!mv '%:p' " .. os.getenv("ZETTELKASTEN") .. '/zettelkasten<cr>:bd<cr>', "Keep Note")
map('n', '<leader>odd', ":!rm '%:p'<cr>:bd<cr>", "Delete Note")

-- Neovim split / Wezterm pane navigation
-- in .config/wezterm/wezterm.lua SUPER|SHIFT + h/j/k/l is mapped to sending CTRL + h/j/k/l if foreground process is Neovim.
map('n', '<C-h>', '<cmd>FocusLeft<cr>', 'Focus Left')
map('n', '<C-j>', '<cmd>FocusDown<cr>', 'Focus Down')
map('n', '<C-k>', '<cmd>FocusUp<cr>', 'Focus Up')
map('n', '<C-l>', '<cmd>FocusRight<cr>', 'Focus Right')

-- nice highlight on yanks
-- see `:help vim.highlight.on_yank()`
-- see `:help vim.api.nvim_create_autocmd()`
-- see `:help vim.api.nvim_create_augroup()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.highlight.on_yank() end,
})
local insertmode_linenum = vim.api.nvim_create_augroup('insertmode-linenum', { clear = true })
-- Relative line numbers in Normal Mode, Absolute in Insert Mode
vim.api.nvim_create_autocmd('InsertEnter', {
  desc = 'Absolute line numbers on entering Insert mode',
  group = insertmode_linenum,
  callback = function() vim.opt.relativenumber = false end
})
vim.api.nvim_create_autocmd('InsertLeave', {
  desc = 'Relative line numbers when exiting Insert mode',
  group = insertmode_linenum,
  callback = function() vim.opt.relativenumber = true end
})
