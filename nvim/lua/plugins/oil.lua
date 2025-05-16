---------
-- Oil --
---------

return {
	'stevearc/oil.nvim',
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {},
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	lazy = false,
	config = function()
		local oil = require("oil")
		oil.setup {
			default_file_explorer = true,
			float = {
				max_width = 0.8,
				max_height = 0.8,
				border = "rounded",
				preview_split = "right",
			},
			-- Configuration for the file preview window
			preview_win = {
				-- Whether the preview window is automatically updated when the cursor is moved
				update_on_cursor_moved = true,
				-- How to open the preview window "load"|"scratch"|"fast_scratch"
				preview_method = "fast_scratch",
			},
		}
	end,
}
