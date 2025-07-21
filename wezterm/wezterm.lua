local wezterm = require("wezterm")

local config = wezterm.config_builder()
local act = wezterm.action
local colors = {}

colors.everforest = {
  tab_bar = {
    background = "#2D353B",
    active_tab = {
      fg_color = "#D3C6AA",
      bg_color = "#56635F",
      intensity = "Bold",
      italic = true,
    },
    inactive_tab = {
      fg_color = "#D3C6AA",
      bg_color = "#2D353B",
      intensity = "Half",
      italic = false,
    },
  },
}


config = {
  automatically_reload_config = true,
  window_close_confirmation = "NeverPrompt",
  window_decorations = "RESIZE",
  default_cursor_style = "BlinkingBar",
  color_scheme_dirs = { "~/.config/wezterm/colors" },
  color_scheme = "Everforest Dark (Medium)",
  line_height = 1.0,
  --	font = wezterm.font("Hasklug Nerd Font", {
  --	font = wezterm.font("MesloLGL Nerd Font", {
  font = wezterm.font("Liga SFMono Nerd Font", {
    weight = "Regular",
    stretch = "Normal",
    style = "Normal",
  }),
  font_size = 20,
  --window_background_opacity = 0.65,
  macos_window_background_blur = 100,
  window_padding = {
    left = 60,
    right = 60,
    top = 30,
    bottom = 5,
  },
  adjust_window_size_when_changing_font_size = false,
  initial_rows = 48,
  initial_cols = 130,
}

-- Tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.show_tabs_in_tab_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 20
config.colors = colors.everforest
--config.text_background_opacity = 0.6

-- Inactiave pane brightness
config.inactive_pane_hsb = {
  --hue = 1.0,
  --saturation = 0.7,
  --brightness = 0.7,
}

config.leader = {
  mods = "SHIFT|SUPER",
  key = " ",
  timeout_milliseconds = 1000,
}

-- Register an event handler for custom "binary-split" event.
wezterm.on("binary-split", function(window, pane)
  local dims = pane:get_dimensions()
  if dims.pixel_width < dims.pixel_height then
    window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
  else
    window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
  end
end)

-- Helper to check if a pane’s foreground process is (Neo)vim.
local function isViProcess(pane)
  local name = pane:get_foreground_process_name()
  if not name then
    return false
  end
  return name:find("nvim") or name:find("vim") -- true if process name contains "vim"
end

-- Generic handler: if pane has Neovim, send Neovim the key, else do WezTerm action.
local function conditionalActivatePane(window, pane, direction, vimKey)
  if isViProcess(pane) then
    -- Forward an Alt/Meta or Ctrl modified key to Neovim.
    window:perform_action(act.SendKey({ key = vimKey, mods = "ALT" }), pane)
  else
    -- Not a Vim pane: perform normal pane navigation
    window:perform_action(act.ActivatePaneDirection(direction), pane)
  end
end

-- Bind the events for each direction
wezterm.on("focus-left", function(win, pane)
  conditionalActivatePane(win, pane, "Left", "h")
end)
wezterm.on("focus-down", function(win, pane)
  conditionalActivatePane(win, pane, "Down", "j")
end)
wezterm.on("focus-up", function(win, pane)
  conditionalActivatePane(win, pane, "Up", "k")
end)
wezterm.on("focus-right", function(win, pane)
  conditionalActivatePane(win, pane, "Right", "l")
end)

wezterm.on("smart-close", function(window, pane)
  if isViProcess(pane) then
    -- Send a Ctrl+q to Neovim to let it decide whether to close a split or call back to wezterm.
    window:perform_action(act.SendKey({ key = "q", mods = "CTRL" }), pane)
  else
    -- If not running Neovim, simply close this pane.
    window:perform_action(act.CloseCurrentPane({ confirm = false }), pane)
  end
end)

config.keys = {
  -- for debugging
  { key = "z", mods = "CTRL", action = wezterm.action.ShowDebugOverlay },
  {
    key = "r",
    mods = "SUPER",
    action = act.PromptInputLine({
      description = "Enter new tab name",
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }),
  },
  -- Create new panes
  {
    key = "t",
    mods = "SHIFT|SUPER",
    action = act.EmitEvent("binary-split"),
  },
  {
    key = "s",
    mods = "SUPER",
    action = act.ActivateKeyTable({
      name = "split_pane",
      one_shot = false,
      until_unknown = true,
      timeout_milliseconds = 1000,
    }),
  },
  -- Close current pane
  {
    key = "w",
    mods = "SHIFT|SUPER",
    action = act.EmitEvent("smart-close"),
  },
  -- Switch pane focus
  {
    key = "H",
    mods = "SHIFT|SUPER",
    action = act.EmitEvent("focus-left"),
  },
  {
    key = "J",
    mods = "SHIFT|SUPER",
    action = act.EmitEvent("focus-down"),
  },
  {
    key = "K",
    mods = "SHIFT|SUPER",
    action = act.EmitEvent("focus-up"),
  },
  {
    key = "L",
    mods = "SHIFT|SUPER",
    action = act.EmitEvent("focus-right"),
  },
  -- Adjust current pane size
  {
    key = "s",
    mods = "SHIFT|SUPER",
    action = act.ActivateKeyTable({
      name = "resize_pane",
      one_shot = false,
      until_unknwon = true,
      timeout_milliseconds = 1000,
    }),
  },
  -- Rotate panes
  {
    key = "z",
    mods = "SHIFT|SUPER",
    action = act.RotatePanes("Clockwise"),
  },
}

config.key_tables = {
  -- Defines the keys that are active in our resize-pane mode.
  -- Since we're likely to want to make multiple adjustments,
  -- we made the activation one_shot=false. We therefore need
  -- to define a key assignment for getting out of this mode.
  -- 'resize_pane' here corresponds to the name="resize_pane" in
  -- the key assignments above.
  split_pane = {
    { key = "h",      action = act.SplitPane({ direction = "Left" }) },
    { key = "l",      action = act.SplitPane({ direction = "Right" }) },
    { key = "k",      action = act.SplitPane({ direction = "Up" }) },
    { key = "j",      action = act.SplitPane({ direction = "Down" }) },
    -- Cancel the mode by pressing escape
    { key = "Escape", action = "PopKeyTable" },
  },

  --close_pane = {
  --    { key = "x", action = act.CloseCurrentPane({ confirm = true }) },
  --},

  resize_pane = {
    { key = "h",      action = act.AdjustPaneSize({ "Left", 5 }) },
    { key = "l",      action = act.AdjustPaneSize({ "Right", 5 }) },
    { key = "k",      action = act.AdjustPaneSize({ "Up", 5 }) },
    { key = "j",      action = act.AdjustPaneSize({ "Down", 5 }) },
    -- Cancel the mode by pressing escape
    { key = "Escape", action = "PopKeyTable" },
  },
}

return config
