----------------------
-- ObsidianTemplate --
----------------------

-- Auto–insert Obsidian template & de-slug titles for any empty Markdown buffer
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    -- only if buffer is completely empty
    if vim.fn.line('$') ~= 1 or vim.fn.getline(1) ~= '' then
      return
    end

    -- Insert your Obsidian template
    vim.cmd('ObsidianTemplate note')

    -- Find the first H1 ("# …"), replace dashes with spaces, then stop
    for i = 1, vim.fn.line('$') do
      local line = vim.fn.getline(i)
      local title = line:match('^# (.+)$')
      if title then
        -- re-write the header with spaces instead of dashes
        vim.fn.setline(i, '# ' .. title:gsub('%-', ' '))
        break
      end
    end
  end,
})
