----------------------------------------------------------
-- Unify pane/split navigation between Nvim and Wezterm --
----------------------------------------------------------

local wezterm_pane = vim.fn.getenv 'WEZTERM_PANE'

local dir_map = {}
dir_map["left"] = "h"
dir_map["down"] = "j"
dir_map["up"] = "k"
dir_map["right"] = "l"

local focus_pane = function(dir)
  -- (1) Attempt to change Neovim window
  local cur_win = vim.api.nvim_get_current_win()
  vim.cmd('wincmd ' .. dir_map[dir])

  -- (2) If Neovim window unchanged, Attempt to change wezterm pane
  if vim.api.nvim_get_current_win() == cur_win then
    if wezterm_pane ~= vim.NIL then
      -- Use WezTerm CLI to move pane. Include --pane-id to be explicit.
      vim.fn.system { 'wezterm', 'cli', 'activate-pane-direction', dir, '--pane-id', wezterm_pane }
    else
      -- Fallback: no env var, just call (works if only one mux client)
      vim.fn.system { 'wezterm', 'cli', 'activate-pane-direction', dir }
    end
  end
end

vim.api.nvim_create_user_command('FocusLeft', function()
  focus_pane("left")
end, { desc = 'Change pane focus left', })

vim.api.nvim_create_user_command('FocusDown', function()
  focus_pane("down")
end, { desc = 'Change pane focus down', })

vim.api.nvim_create_user_command('FocusUp', function()
  focus_pane("up")
end, { desc = 'Change pane focus up', })

vim.api.nvim_create_user_command('FocusRight', function()
  focus_pane("right")
end, { desc = 'Change pane focus right', })
