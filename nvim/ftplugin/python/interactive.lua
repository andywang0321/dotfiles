----------------------------------
-- Interactive iPython Terminal --
----------------------------------

local function toggle_ipy()
	print("Interactive Python!")
end

vim.api.nvim_create_user_command("InteractivePy", toggle_ipy, {})
