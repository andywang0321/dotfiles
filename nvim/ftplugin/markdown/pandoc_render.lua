---------------
-- PandocPDF --
---------------

local save_and_render = function(opts)
  -- pick either the arg or the current file
  local input = opts.args ~= '' and opts.args or vim.fn.expand('%:p')
  -- strip path and extension, keep only basename
  local base = vim.fn.fnamemodify(input, ':t:r')
  -- put the PDF in ~/Documents/zettelrenders/
  local output = vim.fn.expand('~/Documents/zettelrenders') .. base .. '.pdf'
  -- build pandoc cmd with 2cm all-around margin
  local cmd = {
    'pandoc',
    input,
    '-o', output,
    '-V', 'geometry:margin=2cm',
  }
  vim.cmd("write")
  -- fire-and-forget so Neovim stays responsive
  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    on_exit = function(_, code)
      if code == 0 then
        print('🖨️  Generated PDF → ' .. output)
        vim.cmd("!open " .. output)
      else
        print('❌ pandoc failed (exit ' .. code .. ')')
      end
    end,
  })
end

-- When you’re in a markdown buffer, define :PDF
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  --group = vim.api.nvim_create_augroup('pandoc-render', { clear = true }),
  callback = function()
    -- buffer-local user command
    vim.api.nvim_buf_create_user_command(0, 'PDF', save_and_render, {
      nargs = '?',
      complete = function(ArgLead)
        -- offer markdown files in cwd
        return vim.fn.split(vim.fn.glob(ArgLead .. '*.md', false, true), '\n')
      end,
    })
  end,
})
