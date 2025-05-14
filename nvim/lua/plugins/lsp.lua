---------
-- LSP --
---------

--[[

So, what is a Language Server Protocol?

- a protocol that lets the text editor (client) communicate in real time with an external program (server)
- e.g. nvim: "what is the definition of the thing under the cursor?" LSP: "this function is defined in path/to/def"
- e.g. nvim: "the user just typed `f = function end`" LSP: "error! missing parentheses!"

Neovim already has a really nice LSP client built in, it is now just waiting for us to configure the LSP servers.

- check out `:help lsp`!
- once nvim-lspconfig is installed check out `:help lspconfig-all`!

--]]

return {
  "neovim/nvim-lspconfig",
  -- This lets lua-ls stop panicking in our neovim config lua files (remember the 'undefined global: vim' errors?)
  dependencies = {
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = {
	library = {
	  -- See the configuration section for more details
	  -- Load luvit types when the `vim.uv` word is found
	  { path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
      },
    },
  },
  config = function()
    -- require("lspconfig").YOUR_LSP_HERE.setup({})
    -- see `:help lspconfig-all` to find some LSPs!
    require'lspconfig'.lua_ls.setup{}
  end,
}
