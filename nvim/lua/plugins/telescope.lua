---------------
-- Telescope --
---------------

return {
	'nvim-telescope/telescope.nvim',
	tag = '0.1.8',
	dependencies = {
		'nvim-lua/plenary.nvim',
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
	},
	config = function()
		require("telescope").setup { extensions = { fzf = {} } }
		require("telescope").load_extension('fzf')
		local tb = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", tb.find_files)
		vim.keymap.set("n", "<leader>conf", function() tb.find_files { cwd = vim.fn.stdpath("config") } end)
		vim.keymap.set("n", "<leader>oo", function() tb.find_files { cwd = os.getenv("ZETTELKASTEN") } end)
		vim.keymap.set("n", "<leader>help", tb.help_tags)
		-- custom live grep
		local custom = require("custom.telescope.filtergrep")
		vim.keymap.set("n", "<leader>fg", custom.filter_grep)
	end
}
