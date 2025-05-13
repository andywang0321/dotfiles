local custom = require 'core.custom' -- Custom functionality

-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- For conciseness
local opts = { noremap = true, silent = true }

-- Moveing line/selection
vim.keymap.set('n', '<A-j>', ':m +1<CR>', opts)
vim.keymap.set('n', '<A-k>', ':m -2<CR>', opts)
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", opts)
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", opts)

-- Map <leader>i in Normal mode to trigger the debug_or_toggle function.
vim.keymap.set('n', '<leader>i', custom.debug_or_toggle,
  { desc = 'Toggle [I]nteractive Pane', noremap = true, silent = true })
-- Map <Shift-ENTER> in visual mode to send the visually selected text to the debug pane.
vim.keymap.set('v', '<S-CR>', custom.send_selection,
  { desc = 'Send Selection to Interactive', noremap = true, silent = true })
-- Map <Shift-ENTER> in normal or insert mode to send current line to the debug pane.
vim.keymap.set({ 'n', 'i' }, '<S-CR>', custom.send_line,
  { desc = 'Send Line to Interactive', noremap = true, silent = true })
-- Map <leader><ENTER> in normal mode to send newlines to the debug pane.
vim.keymap.set('n', '<leader><CR>', custom.send_newline,
  { desc = 'Send Newline to Interactive', noremap = true, silent = true })
-- Map <leader>p in normal mode to send the entire buffer to the debug pane.
vim.keymap.set('n', '<leader>p', custom.send_buffer,
  { desc = 'Send Buffer to Interactive', noremap = true, silent = true })

-- Obsidian vault
local zettelkasten = '/Users/andywang/Library/Mobile\\ Documents/iCloud~md~obsidian/Documents/Zettelkasten'
-- navigate to vault
vim.keymap.set('n', '<leader>oo', ':cd ' .. zettelkasten .. '<cr>',
  { desc = '[O]pen [O]bsidian Vault', noremap = true, silent = true })
-- convert note to template and remove leading white space
vim.keymap.set(
  'n',
  '<leader>ot',
  ':ObsidianTemplate note<cr> :lua vim.cmd([[1,/^\\S/s/^\\n\\{1,}//]])<cr>',
  { desc = '[O]bsidian [T]emplate', noremap = true, silent = true }
)

-- Obsidian review workflow
-- move file in current buffer to zettelkasten folder
vim.keymap.set('n', '<leader>ok', ":!mv '%:p' " .. zettelkasten .. '/zettelkasten<cr>:bd<cr>', opts)
-- delete file in current buffer
vim.keymap.set('n', '<leader>odd', ":!rm '%:p'<cr>:bd<cr>", opts)

-- Delete single character without copying into register
vim.keymap.set('n', 'x', '"_x', opts)

-- Vertical scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- Resize with arrows
vim.keymap.set('n', '<Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>', opts)

-- Buffers
vim.keymap.set('n', '<leader>]', ':bnext<CR>', opts)
vim.keymap.set('n', '<leader>[', ':bprevious<CR>', opts)
vim.keymap.set('n', '<leader>x', ':bdelete!<CR>', opts) -- close buffer
--vim.keymap.set('n', '<leader>b', '<cmd> enew <CR>', opts) -- new buffer

-- Window management
vim.keymap.set('n', '<leader>wl', '<C-w>v', opts) -- split window vertically
vim.keymap.set('n', '<leader>wj', '<C-w>s', opts) -- split window horizontally
vim.keymap.set('n', '<leader>w=', '<C-w>=', opts) -- make split windows equal width & height
vim.keymap.set('n', '<C-q>', ':q<CR>', opts)      -- close current split window
vim.keymap.set('n', '<leader>t', function()
  custom.binary_split()
end, opts) -- create binary split

-- Navigate between splits
vim.keymap.set('n', '<C-k>', function()
  custom.move_or_pane('k', 'up')
end, opts)
vim.keymap.set('n', '<C-j>', function()
  custom.move_or_pane('j', 'down')
end, opts)
vim.keymap.set('n', '<C-h>', function()
  custom.move_or_pane('h', 'left')
end, opts)
vim.keymap.set('n', '<C-l>', function()
  custom.move_or_pane('l', 'right')
end, opts)

-- Tabs
vim.keymap.set('n', '<leader>tt', ':tabnew<CR>', opts)   -- open new tab
vim.keymap.set('n', '<leader>tw', ':tabclose<CR>', opts) -- close current tab
vim.keymap.set('n', '<leader>t]', ':tabn<CR>', opts)     --  go to next tab
vim.keymap.set('n', '<leader>t[', ':tabp<CR>', opts)     --  go to previous tab

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Keep last yanked when pasting
vim.keymap.set('v', 'p', '"_dP', opts)

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>d[', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', '<leader>d]', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
