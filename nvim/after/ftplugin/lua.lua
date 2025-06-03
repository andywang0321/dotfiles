-------------
-- Lua.lua --
-------------

-- config options in `after` folder gets loaded AFTER main configs get loaded
-- this is helpful if you want to overwrite default config options for specific filetypes
-- `ftplugin` stand for "file type plugins"

local set = vim.opt_local
-- for lua files, indent only 2 spaces
set.shiftwidth = 2
set.number = true
set.relativenumber = true
