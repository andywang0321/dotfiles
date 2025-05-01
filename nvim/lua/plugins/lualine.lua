return {
  'nvim-lualine/lualine.nvim',
  config = function()
    local mode = {
      'mode',
      fmt = function(str)
        return ' ' .. str
        -- return ' ' .. str:sub(1, 1) -- displays only the first character of the mode
      end,
    }

    local buffers = {
      'buffers',
      show_filename_only = true,       -- Shows shortened relative path when set to false.
      hide_filename_extension = false, -- Hide filename extension when set to true.
      show_modified_status = true,     -- Shows indicator when the buffer is modified.

      mode = 0,                        -- 0: Shows buffer name
      -- 1: Shows buffer index
      -- 2: Shows buffer name + buffer index
      -- 3: Shows buffer number
      -- 4: Shows buffer name + buffer number

      --user_mode_colors = true,

      buffers_color = {
        -- Same values as the general color option can be used here.
        active = 'MyBufferActive',     -- Color for active buffer.
        inactive = 'MyBufferInactive', -- Color for inactive buffer.
      },

      symbols = {
        modified = ' ●', -- Text to show when the buffer is modified
        alternate_file = '', -- Text to show to identify the alternate file
        directory = '', -- Text to show when the buffer is a directory
      },
    }

    local hide_in_width = function()
      return vim.fn.winwidth(0) > 100
    end

    local diagnostics = {
      'diagnostics',
      sources = { 'nvim_diagnostic' },
      sections = { 'error', 'warn' },
      symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
      colored = false,
      update_in_insert = false,
      always_visible = false,
      cond = hide_in_width,
    }

    local diff = {
      'diff',
      colored = false,
      symbols = { added = ' ', modified = ' ', removed = ' ' }, -- changes diff symbols
      cond = hide_in_width,
    }

    require('lualine').setup {
      options = {
        icons_enabled = true,
        --theme = 'catppuccin', -- Set theme based on environment variable
        --theme = 'everforest',
        -- Some useful glyphs:
        -- https://www.nerdfonts.com/cheat-sheet
        --        
        --section_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        component_separators = { left = '|', right = '|' },
        disabled_filetypes = { 'alpha', 'neo-tree' },
        always_divide_middle = true,
      },
      sections = {
        lualine_a = { mode },
        lualine_b = { 'branch' },
        --lualine_c = { filename },
        lualine_c = { buffers },
        lualine_x = {
          diagnostics,
          diff,
          { 'encoding', cond = hide_in_width },
          { 'filetype', cond = hide_in_width },
        },
        lualine_y = { 'location' },
        lualine_z = { 'progress' },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { { 'location', padding = 0 } },
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {},
      extensions = { 'fugitive' },
    }
  end,
}
