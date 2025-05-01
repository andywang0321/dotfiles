local M = {}

M.duplicate_selection = function()
  local start_line, end_line = vim.fn.line "'<", vim.fn.line "'>"
  vim.cmd(string.format('%d,%dt%d', start_line, end_line, end_line))
end

-- Helper: Find the debug pane by searching for a pane running ipython/python
M.get_debug_pane = function()
  local list = vim.fn.systemlist 'wezterm cli list'
  for _, line in ipairs(list) do
    if not line:match '^%s*WINID' then
      local lower_line = line:lower()
      -- Look for ipython first; otherwise, look for python and exclude any nvim pane.
      if lower_line:find 'ipython' or (lower_line:find 'python' and not lower_line:find 'nvim') then
        local _, _, paneid = line:match '^%s*(%S+)%s+(%S+)%s+(%S+)'
        if paneid then
          return paneid
        end
      end
    end
  end
  return nil
end

-- Helper: Send text to a given pane via wezterm cli send-text.
M.send_text_to_pane = function(pane_id, text)
  local send_cmd = 'wezterm cli send-text --pane-id ' .. pane_id
  local job = vim.fn.jobstart(send_cmd, { stdin = 'pipe' })
  if job > 0 then
    vim.fn.chansend(job, text)
    vim.fn.chanclose(job, 'stdin')
  else
    vim.notify('Failed to send text to pane ' .. pane_id, vim.log.levels.ERROR)
  end
end

-- Create a new debug pane by splitting the current pane to the right.
M.create_debug_pane = function()
  local neovim_pane = os.getenv 'WEZTERM_PANE'
  if not neovim_pane then
    vim.notify('Not running in WezTerm!', vim.log.levels.ERROR)
    return nil
  end

  -- Determine the activation command based on the current environment.
  local conda_prefix = os.getenv 'CONDA_PREFIX' or ''
  local venv = os.getenv 'VIRTUAL_ENV' or ''
  local activation_command = ''
  local env_name = ''
  if conda_prefix ~= '' and conda_prefix ~= '/Users/andywang/anaconda3' then
    env_name = conda_prefix:match '.*/(.*)'
    activation_command = 'conda activate ' .. env_name .. ' && '
  elseif venv ~= '' then
    activation_command = 'source ' .. venv .. '/bin/activate && '
    env_name = venv
  else
    local cwd = vim.fn.getcwd()
    if vim.fn.isdirectory(cwd .. '/.venv') == 1 then
      activation_command = 'source .venv/bin/activate && '
      env_name = '.venv'
    else
      activation_command = 'source /Users/andywang/devenv/bin/activate && '
      env_name = 'devenv'
    end
  end

  -- Compose the command to run in the new pane.
  -- We launch a new zsh login shell that first activates the environment,
  -- then attempts to run ipython (falling back to python), and finally keeps the shell alive.
  local new_cmd = activation_command .. 'echo "Activated ' .. env_name .. '"; ipython || python; exec zsh'
  local split_cmd = 'wezterm cli split-pane --right --pane-id ' ..
  neovim_pane .. ' -- zsh -c ' .. vim.fn.shellescape(new_cmd)
  local output = vim.fn.systemlist(split_cmd)
  local debug_pane = output[1] or nil
  return debug_pane
end

-- Send all import lines (those beginning with "import" or "from") from the current buffer to the debug pane.
-- Any leading whitespace is removed so that imports from indented blocks are sent without indentation.
M.send_imports_to_debug = function()
  local debug_pane = M.get_debug_pane()
  if not debug_pane then
    vim.notify('[Send imports] Debug pane not found', vim.log.levels.ERROR)
    return
  end

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local import_lines = {}
  for _, line in ipairs(lines) do
    if line:match '^%s*import' or line:match '^%s*from' then
      local clean_line = line:gsub('^%s+', '')
      table.insert(import_lines, clean_line)
    end
  end
  if #import_lines == 0 then
    vim.notify('No import lines found', vim.log.levels.INFO)
    return
  end

  local code = table.concat(import_lines, '\n')
  M.send_text_to_pane(debug_pane, code)

  -- After a brief delay, send a newline (using --no-paste) to trigger execution.
  vim.defer_fn(function()
    local newline_cmd = 'wezterm cli send-text --pane-id ' .. debug_pane .. ' --no-paste'
    local njob = vim.fn.jobstart(newline_cmd, { stdin = 'pipe' })
    if njob > 0 then
      vim.fn.chansend(njob, '\n')
      vim.fn.chanclose(njob, 'stdin')
    end
  end, 200)
end

-- Main function: if no debug pane exists, create it; otherwise, toggle zoom on the current (Neovim) pane.
M.debug_or_toggle = function()
  local debug_pane = M.get_debug_pane()
  local neovim_pane = os.getenv 'WEZTERM_PANE'
  if not neovim_pane then
    vim.notify('Not running in WezTerm!', vim.log.levels.ERROR)
    return
  end

  if not debug_pane then
    -- Create the debug pane.
    debug_pane = M.create_debug_pane()
    if not debug_pane then
      vim.notify('Failed to create debug pane', vim.log.levels.ERROR)
      return
    end
    -- Wait for the new pane to initialize, then send the import lines,
    -- and finally return focus to the Neovim pane.
    vim.defer_fn(function()
      M.send_imports_to_debug()
      local act_cmd = 'wezterm cli activate-pane --pane-id ' .. neovim_pane
      vim.fn.system(act_cmd)
    end, 500)
  else
    -- If a debug pane already exists, toggle the zoom state of the Neovim pane.
    local toggle_cmd = 'wezterm cli zoom-pane --pane-id ' .. neovim_pane .. ' --toggle'
    --vim.fn.jobstart(toggle_cmd)
    vim.fn.system(toggle_cmd)
  end
end

-- Simplified function to send code to the debug pane
M.send_code_to_debug = function(code)
  local debug_pane = M.get_debug_pane()
  if not debug_pane then
    debug_pane = M.create_debug_pane()
    if not debug_pane then
      vim.notify('Failed to create debug pane', vim.log.levels.ERROR)
      return
    end
    -- Wait for the pane to initialize before sending code.
    vim.defer_fn(function()
      M.send_text_to_pane(debug_pane, code)
      vim.defer_fn(function()
        local newline_cmd = 'wezterm cli send-text --pane-id ' .. debug_pane .. ' --no-paste'
        local njob = vim.fn.jobstart(newline_cmd, { stdin = 'pipe' })
        if njob > 0 then
          vim.fn.chansend(njob, '\n')
          vim.fn.chanclose(njob, 'stdin')
        end
      end, 200)
    end, 500)
  else
    M.send_text_to_pane(debug_pane, code)
    vim.defer_fn(function()
      local newline_cmd = 'wezterm cli send-text --pane-id ' .. debug_pane .. ' --no-paste'
      local njob = vim.fn.jobstart(newline_cmd, { stdin = 'pipe' })
      if njob > 0 then
        vim.fn.chansend(njob, '\n')
        vim.fn.chanclose(njob, 'stdin')
      end
    end, 200)
  end
end

-- Visual mode helper: get exact visual selection using register z
M.get_visual_selection = function()
  local orig_reg = vim.fn.getreg '"'
  local orig_regtype = vim.fn.getregtype '"'
  local orig_z = vim.fn.getreg 'z'
  local orig_ztype = vim.fn.getregtype 'z'

  vim.cmd 'normal! "zy'
  local selection = vim.fn.getreg 'z'

  vim.fn.setreg('z', orig_z, orig_ztype)
  vim.fn.setreg('"', orig_reg, orig_regtype)

  return selection
end

-- Send the visually selected text to the debug pane
M.send_selection = function()
  local code = M.get_visual_selection()
  M.send_code_to_debug(code)
end

-- Send newlines to the debug pane
M.send_newline = function()
  M.send_code_to_debug '\n\n'
end

-- Send the entire buffer to the debug pane
M.send_buffer = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code = table.concat(lines, '\n')
  M.send_code_to_debug(code)
  M.send_code_to_debug '\n\n'
end

-- Send current line to the debug pane, then move one line below.
M.send_line = function()
  local line = vim.api.nvim_get_current_line()
  M.send_code_to_debug(line)
  vim.cmd 'exe "normal j"'
end

--------------------------------
-- Unify Wezterm and Nvim splits
--------------------------------

local wezterm_pane = vim.fn.getenv 'WEZTERM_PANE'
M.move_or_pane = function(dir, pane_dir)
  -- Attempt to move Neovim window
  local cur_win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. dir)
  if vim.api.nvim_get_current_win() == cur_win then
    -- No change in window, so no split in that direction
    if wezterm_pane ~= vim.NIL then
      -- Use WezTerm CLI to move pane. Include --pane-id to be explicit.
      vim.fn.system { 'wezterm', 'cli', 'activate-pane-direction', pane_dir, '--pane-id', wezterm_pane }
    else
      -- Fallback: no env var, just call (works if only one mux client)
      vim.fn.system { 'wezterm', 'cli', 'activate-pane-direction', pane_dir }
    end
  end
end

local cached_size = {
  screen_x = 0,
  screen_y = 0,
  screen_cols = 0,
  screen_rows = 0,
  cell_width = 0,
  cell_height = 0,
}

local function update_size()
  local ffi = require 'ffi'
  ffi.cdef [[
    typedef struct {
      unsigned short row;
      unsigned short col;
      unsigned short xpixel;
      unsigned short ypixel;
    } winsize;
    int ioctl(int, int, ...);
  ]]

  local TIOCGWINSZ = nil
  if vim.fn.has 'linux' == 1 then
    TIOCGWINSZ = 0x5413
  elseif vim.fn.has 'mac' == 1 then
    TIOCGWINSZ = 0x40087468
  elseif vim.fn.has 'bsd' == 1 then
    TIOCGWINSZ = 0x40087468
  end

  local sz = ffi.new 'winsize'
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
vim.api.nvim_create_autocmd('VimResized', { callback = update_size })

local function binary_split()
  local size = cached_size
  local current_win = vim.api.nvim_get_current_win()
  local cell_width = size.cell_width
  local cell_height = size.cell_height
  local win_width_cells = vim.api.nvim_win_get_width(current_win)
  local win_height_cells = vim.api.nvim_win_get_height(current_win)
  local pixel_width = win_width_cells * cell_width
  local pixel_height = win_height_cells * cell_height

  if pixel_width > pixel_height then
    vim.cmd 'vsplit'
  else
    vim.cmd 'split'
  end
end

M.binary_split = binary_split

return M
