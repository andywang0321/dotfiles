return {
  'neanias/everforest-nvim',
  version = false,
  lazy = false,
  priority = 1000, -- make sure to load this before all the other start plugins
  -- Optional; default configuration will be used if setup isn't called.
  config = function()
    require('everforest').setup {
      on_highlights = function(hl, palette)
        hl.MyBufferActive = { fg = palette.bg_dim, bg = palette.statusline1 }
        hl.MyBufferInactive = { fg = palette.gray1, bg = palette.bg1 }
      end,
    }
    vim.cmd.colorscheme 'everforest'
  end,
}
