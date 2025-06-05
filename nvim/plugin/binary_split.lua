------------------
-- Binary Split --
------------------

local cached_size = {
  screen_x = 0,
  screen_y = 0,
  screen_cols = 0,
  screen_rows = 0,
  cell_width = 0,
  cell_height = 0,
}

local function update_size()
  local ffi = require('ffi')
  ffi.cdef([[
    typedef struct {
      unsigned short row;
      unsigned short col;
      unsigned short xpixel;
      unsigned short ypixel;
    } winsize;
    int ioctl(int, int, ...);
  ]])

  local TIOCGWINSZ = nil
  if vim.fn.has('linux') == 1 then
    TIOCGWINSZ = 0x5413
  elseif vim.fn.has('mac') == 1 then
    TIOCGWINSZ = 0x40087468
  elseif vim.fn.has('bsd') == 1 then
    TIOCGWINSZ = 0x40087468
  end

  local sz = ffi.new('winsize')
  assert(ffi.C.ioctl(1, TIOCGWINSZ, sz) == 0, 'Failed to get terminal size')

  cached_size = {
    screen_x = sz.xpixel,
    screen_y = sz.ypixel,
    screen_cols = sz.col,
    screen_rows = sz.row,
    cell_width = sz.xpixel / sz.col,
    cell_height = sz.ypixel / sz.row,
  }
end

-- Initialize size on startup.
update_size()
-- Update cached_size when Neovim is resized.
vim.api.nvim_create_autocmd('VimResized', {
  group = vim.api.nvim_create_augroup('vim-resized', { clear = true }),
  callback = update_size,
})

local binary_split = function()
  local size = cached_size
  local current_win = vim.api.nvim_get_current_win()
  local cell_width = size.cell_width
  local cell_height = size.cell_height
  local win_width_cells = vim.api.nvim_win_get_width(current_win)
  local win_height_cells = vim.api.nvim_win_get_height(current_win)
  local pixel_width = win_width_cells * cell_width
  local pixel_height = win_height_cells * cell_height

  if pixel_width > pixel_height then
    vim.cmd('vsplit')
  else
    vim.cmd('split')
  end
end

vim.api.nvim_create_user_command('BinarySplit', binary_split, { desc = 'Create split intelligently' })
