return {
  'neanias/everforest-nvim',
  version = false,
  lazy = false,
  priority = 1000, -- make sure to load this before all the other start plugins
  -- Optional; default configuration will be used if setup isn't called.
  config = function()
    require('everforest').setup {
      ---How much of the background should be transparent. 2 will have more UI components be transparent (e.g. status line background)
      transparent_background_level = 2,
      on_highlights = function(hl, palette)
        hl.MyBufferActive = { fg = palette.bg_dim, bg = palette.statusline1 }
        hl.MyBufferInactive = { fg = palette.gray1, bg = palette.bg1 }
      end,
    }
    vim.cmd.colorscheme 'everforest'
  end,
}
