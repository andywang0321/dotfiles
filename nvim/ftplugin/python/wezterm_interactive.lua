local state = { ipy_pane_id = -1, nvim_pane_id = -1 }

-- Create and Manage Pane

local create_ipy_pane = function()
  assert(state.ipy_pane_id == -1, "Wezterm iPython pane already exists!")
  state.nvim_pane_id = os.getenv("WEZTERM_PANE")
  state.ipy_pane_id = vim.fn.system(
    'wezterm cli split-pane --right -- ' ..
    'env MPLBACKEND="kitcat" ' ..
    'uv run --with ipython ipython'
  )
  vim.fn.system("wezterm cli activate-pane --pane-id " .. state.nvim_pane_id)
end

local toggle_ipy_pane = function()
  assert(state.ipy_pane_id ~= -1, "No Wezterm iPython pane to toggle!")
  assert(state.nvim_pane_id ~= -1, "Wezterm iPython pane not attached to nvim pane!")
  vim.fn.system("wezterm cli zoom-pane --pane-id " .. state.nvim_pane_id .. " --toggle")
end

local toggle_wezterm_ipy = function()
  if state.ipy_pane_id == -1 then
    create_ipy_pane()
  else
    toggle_ipy_pane()
  end
end

local kill_ipy_pane = function()
  assert(state.ipy_pane_id ~= -1, "No Wezterm iPython pane to kill!")
  vim.fn.system("wezterm cli kill-pane --pane-id " .. state.ipy_pane_id)
  state.ipy_pane_id = -1
  state.nvim_pane_id = -1
end

vim.api.nvim_create_autocmd("VimLeavePre", {
  desc = "Kill Wezterm iPython panes on exit.",
  pattern = "*.py",
  group = vim.api.nvim_create_augroup('wezterm-ipython', { clear = true }),
  callback = kill_ipy_pane,
})

-- Send line(s)

local send_text_to_ipy = function(text)
  assert(state.ipy_pane_id ~= -1, "No Wezterm iPython pane to send lines to!")
  local job_id = vim.fn.jobstart("wezterm cli send-text --pane-id " .. state.ipy_pane_id .. " --no-paste")
  assert(job_id > 0, "Failed to start Wezterm send-text job!")
  vim.fn.chansend(job_id, text)
  vim.fn.chanclose(job_id)
end

local send_enter_to_ipy = function()
  vim.defer_fn(function()
    vim.fn.system("echo '' | wezterm cli send-text --no-paste --pane-id " .. state.ipy_pane_id)
  end, 50)
end

local send_line_to_ipy = function()
  local line = vim.api.nvim_get_current_line()
  send_text_to_ipy(line)
  send_enter_to_ipy()
  if vim.fn.line(".") == vim.fn.line("$") then
    send_enter_to_ipy()
  else
    vim.cmd("norm j")
  end
end

local get_selection = function()
  local orig_z = vim.fn.getreg('z')
  local orig_ztype = vim.fn.getregtype('z')
  vim.cmd('norm "zy')
  local selection = vim.fn.getreg('z')
  vim.fn.setreg('z', orig_z, orig_ztype)
  return selection
end

local send_selection_to_ipy = function()
  local selection = get_selection()
  send_text_to_ipy(selection)
  send_enter_to_ipy()
end

vim.api.nvim_create_user_command('WeztermIpythonToggle', toggle_wezterm_ipy, { desc = "Toggle Wezterm iPython pane" })

vim.api.nvim_create_user_command('WeztermIpythonSendLine', send_line_to_ipy,
  { desc = "Send line to Wezterm iPython pane" })

vim.api.nvim_create_user_command('WeztermIpythonSendRange', send_selection_to_ipy,
  { desc = "Send range to Wezterm iPython pane" })
