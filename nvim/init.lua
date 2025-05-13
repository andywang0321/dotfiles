-- :source %		sources this file
-- :lua			runs selected lines of lua
-- :lua ...		runs ...

print("Advent of Neovim! Hello my OWN config!")

print("line 1")
print("line 2")
print("line 3")
print("line 4")

MyCoolFunction = function() print "oh my goodness" end
MyCoolFunction()

local fib_mt = {
	__index = function(self, key)
		if key < 2 then return 1 end
		self[key] = self[key - 2] + self[key - 1]
		return self[key]
	end
}

local fib = setmetatable({}, fib_mt)

print(#fib)
print(fib[5])
for k, v in pairs(fib) do print(k, v) end
print(fib[1000])
print(#fib)

-- keymaps for easy executions
vim.keymap.set("n", "<space><space>x", "<cmd>source %<CR>")	-- same as ":source %<CR>"
vim.keymap.set("n", "<space>x", ":.lua<CR>")
vim.keymap.set("v", "<space>x", ":lua<CR>")

-- nice highlight on yanks
-- see `:help vim.highlight.on_yank()`
-- see `:help vim.api.nvim_create_autocmd()`
-- see `:help vim.api.nvim_create_augroup()`
vim.api.nvim_create_autocmd('TextYankPost', {
	desc = 'Highlight when yanking text',
	group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
	callback = function() vim.highlight.on_yank() end,
})
