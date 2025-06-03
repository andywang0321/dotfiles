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
  -- This lets lua-ls stop panicking in our neovim config lua files (remember the "undefined global: vim" errors?)
  dependencies = {
    'saghen/blink.cmp',
    {
      "folke/lazydev.nvim",
      ft = "lua", -- only load on lua files
      opts = { library = { path = "${3rd}/luv/library", words = { "vim%.uv" } }, },
    },
  },
  config = function()
    -- make LSPs talk to blink.cmp
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- require("lspconfig").YOUR_LSP_HERE.setup { capabilities = capabilities }
    -- see `:help lspconfig-all` to find some LSPs!
    local lsp = require("lspconfig")
    lsp.lua_ls.setup { capabilities = capabilities }
    lsp.ruff.setup { capabilities = capabilities }
    lsp.basedpyright.setup { capabilities = capabilities }
    lsp.marksman.setup { capabilities = capabilities }

    -- keymaps, for more see `:help vim.lsp.buf`
    local map = function(keys, func, desc) vim.keymap.set("n", keys, func, { desc = "LSP: " .. desc }) end
    map("K", vim.lsp.buf.hover, "Hover Documentation")
    map("<leader>act", vim.lsp.buf.code_action, "Code Actions")
    map("<leader>name", vim.lsp.buf.rename, "Rename")
    local tb = require("telescope.builtin")
    map("<leader>def", tb.lsp_definitions, "Goto Definition")
    map("<leader>ref", tb.lsp_references, "Goto References")
    map("<leader>imp", tb.lsp_implementations, "Goto Implementation")
    map("<leader>type", tb.lsp_type_definitions, "Goto Type Definition")
    map("<leader>sym", tb.lsp_document_symbols, "Document Symbols")



    -- on LspAttach, enable the following features
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        -- highlight references to word under cursor
        if client.server_capabilities.documentHighlightProvider then
          vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = args.buf, callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = args.buf, callback = vim.lsp.buf.clear_references,
          })
        end

        -- format buffer on save
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = args.buf,
            callback = function() vim.lsp.buf.format({ bufnr = args.buf, id = client.id }) end,
          })
        end
      end,
    })
  end,
}
