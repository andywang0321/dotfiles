----------------------------------
-- Interactive iPython Terminal --
----------------------------------

-- global state so it survives buffer switches
vim.g.ipy_buf = vim.g.ipy_buf or nil
vim.g.ipy_win = vim.g.ipy_win or nil

-- create or toggle the IPython side terminal
local function toggle_ipy()
  -- if it already exists, close it
  if vim.g.ipy_win and vim.api.nvim_win_is_valid(vim.g.ipy_win) then
    vim.api.nvim_win_close(vim.g.ipy_win, true)
    vim.g.ipy_win = nil
    return
  end

  -- otherwise: split and open (or reuse) the terminal buffer
  local curwin = vim.api.nvim_get_current_win()

  vim.cmd("botright vsplit")
  local win = vim.api.nvim_get_current_win()

  local buf = vim.g.ipy_buf
  if buf and vim.api.nvim_buf_is_valid(buf) then
    -- reuse existing IPython buffer
    vim.api.nvim_win_set_buf(win, buf)
  else
    -- create a new scratch buffer & launch IPython
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, buf)
    -- start ipython in your cwd
    vim.fn.termopen('uv run --with ipython ipython', { cwd = vim.fn.getcwd() })
    vim.api.nvim_set_option_value('buflisted', false, { buf = buf }) -- unlist ipython buffer so it's not in `:ls`
    vim.g.ipy_buf = buf
  end

  vim.g.ipy_win = win
  vim.cmd("norm G")
  vim.api.nvim_set_current_win(curwin)
end

-- send lines [start..finish] from the current buffer into that IPython job
local function send_to_ipy(lines)
  -- ensure terminal exists
  if not (vim.g.ipy_buf and vim.api.nvim_buf_is_valid(vim.g.ipy_buf)) then toggle_ipy() end
  if not (vim.g.ipy_win and vim.api.nvim_win_is_valid(vim.g.ipy_win)) then toggle_ipy() end

  local chunk = "\x1b[200~" .. table.concat(lines, "\n") .. "\x1b[201~\r"
  local ok, job_id = pcall(vim.api.nvim_buf_get_var, vim.g.ipy_buf, 'terminal_job_id')
  if not ok or not job_id then
    vim.notify('IPython job not found', vim.log.levels.ERROR)
    return
  end
  vim.fn.chansend(job_id, chunk)
end

local function get_lines(start_line, finish_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, finish_line, false)
  return lines
end

-- toggle iPython terminal
vim.api.nvim_create_user_command('IpyToggle', function()
  if vim.bo.filetype ~= 'python' then
    vim.notify(':ipython is only available in Python files', vim.log.levels.ERROR)
    return
  end
  toggle_ipy()
end, { desc = 'Toggle IPython side terminal (Python buffers only)', force = true, })

-- send the current line
vim.api.nvim_create_user_command('IpySendLine', function()
  local ln = vim.api.nvim_win_get_cursor(0)[1]
  send_to_ipy(get_lines(ln, ln))
  vim.cmd("normal! j")
end, { desc = 'Send current line to IPython', })

-- send a range of lines
vim.api.nvim_create_user_command('IpySendRange', function(opts)
  send_to_ipy(get_lines(opts.line1, opts.line2))
  send_to_ipy({ "", "" })
end, { desc = 'Send lines to IPython', range = true, })

-- create a dedicated augroup so we don’t double-register
local aug = vim.api.nvim_create_augroup('IpyKillOnQuit', {})
vim.api.nvim_create_autocmd('QuitPre', {
  group = aug,
  callback = function()
    if vim.g.ipy_buf and vim.api.nvim_buf_is_valid(vim.g.ipy_buf) then
      local ok, job_id = pcall(vim.api.nvim_buf_get_var, vim.g.ipy_buf, 'terminal_job_id')
      if ok and job_id then
        vim.fn.jobstop(job_id)
      end
    end
  end,
})
