require 'core.options' -- Load general options
require 'core.keymaps' -- Load general keymaps
require 'core.snippets' -- Custom code snippets

-- Set up the Lazy plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Set up plugins
require('lazy').setup {
  --require 'plugins.alpha',
  require 'plugins.autocompletion',
  --require("plugins.bufferline"),
  --require 'plugins.catppuccin',
  --require 'plugins.everforest',
  require 'plugins.debugger',
  require 'plugins.gitsigns',
  require 'plugins.indent-blankline',
  --require 'plugins.kanagawa',
  require 'plugins.lsp',
  require 'plugins.lualine',
  require 'plugins.misc',
  require 'plugins.none-ls',
  require 'plugins.obsidian',
  require 'plugins.oil',
  --require("plugins.smart-splits"),
  require 'plugins.telescope',
  require 'plugins.treesitter',
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
