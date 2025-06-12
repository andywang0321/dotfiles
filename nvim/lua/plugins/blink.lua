-----------------------------
-- Blink Completion Engine --
-----------------------------

return {
	'saghen/blink.cmp',
	enabled = true,
	dependencies = { 'rafamadriz/friendly-snippets' },
	version = '1.*',

	opts = {
		-- See :h blink-cmp-config-keymap for defining your own keymap
		keymap = {
			preset = 'none',
			['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
			['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
			['<CR>'] = { 'select_and_accept', 'fallback' },
			['<C-k>'] = { 'scroll_documentation_up', 'fallback' },
			['<C-j>'] = { 'scroll_documentation_down', 'fallback' },
			['<C-e>'] = { 'show', 'hide', 'fallback' },
			['<C-h>'] = { 'show_documentation', 'hide_documentation', 'fallback' },
			['<C-l>'] = { 'show_signature', 'hide_signature', 'fallback' },
		},
		cmdline = { keymap = { preset = 'inherit' }, completion = { menu = { auto_show = false } }, },
		appearance = { nerd_font_variant = 'mono' },
		-- (Default) Only show the documentation popup when manually triggered
		completion = { documentation = { auto_show = true } },
		fuzzy = { implementation = "prefer_rust_with_warning" },
		signature = { enabled = true, window = { show_documentation = true } },
	},
}
