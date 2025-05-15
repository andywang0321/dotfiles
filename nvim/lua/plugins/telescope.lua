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
		local map = function(keys, func, desc) vim.keymap.set("n", keys, func, { desc = "Telescope: " .. desc }) end
		local tb = require("telescope.builtin")
		map("<leader>ff", tb.find_files, "Find Files")
		map("<leader>fg", require("custom.telescope.filtergrep").filter_grep, "Live Grep with Filtering")
		map("<leader>conf", function() tb.find_files { cwd = vim.fn.stdpath("config") } end, "Neovim Config")
		map("<leader>oo", function() tb.find_files { cwd = os.getenv("ZETTELKASTEN") } end, "Obsidian Vault")
		map("<leader>help", tb.help_tags, "Find Help")
		map("<leader>spell", tb.spell_suggest, "Spelling Suggestions")
		map("<leader>reg", tb.registers, "Registers")
		map("<leader>comm", tb.command_history, "Command History")
		map("<leader>buff", tb.buffers, "Buffers")
		map("<leader>diag", tb.diagnostics, "Diagnostics")
	end
}
