----------------
-- Treesitter --
----------------

--[[

What is tree-sitter?
from https://tree-sitter.github.io/tree-sitter/:

"""
Tree-sitter is a parser generator tool and an incremental parsing library.
It can build a concrete syntax tree for a source file and efficiently update the syntax tree as the source file is edited.
Tree-sitter aims to be:

  - General enough to parse any programming language
  - Fast enough to parse on every keystroke in a text editor
  - Robust enough to provide useful results even in the presence of syntax errors
  - Dependency-free so that the runtime library (which is written in pure C11) can be embedded in any application
"""

Neovim actually comes with tree-sitter parsing engine installed! (did you notice the default syntax highlighting?)
So why do we still need to install a treesitter.nvim plugin?

  - This plugin enables the user to easily access the syntax tree
  - Having easy access to the syntax tree enables users to easily define custom behavior
  - The default treesitter engine lacks support for the constantly updating library of parsers.
    This plugin gives access to them.

--]]

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require'nvim-treesitter.configs'.setup {
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
      sync_install = false,
      auto_install = true,
      highlight = {
	enable = true,
	-- disable slow treesitter highlight for large files
	disable = function(lang, buf)
	  local max_filesize = 100 * 1024 -- 100 KB
	  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
	  if ok and stats and stats.size > max_filesize then
	    return true
	  end
	end,
	additional_vim_regex_highlighting = false,
      },
    }
  end
}
