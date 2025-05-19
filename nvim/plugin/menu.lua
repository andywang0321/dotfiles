--------------------------------------
-- Custom PopUp Menu on Right Click --
--------------------------------------
vim.cmd [[
	aunmenu PopUp
	nnoremenu PopUp.Copy\ Line				yy
	vnoremenu PopUp.Copy\ Selection		y
	anoremenu PopUp.Paste							p
	anoremenu PopUp.Select\ All				ggVG
	anoremenu PopUp.Inspect						<cmd>Inspect<cr>
	amenu PopUp.-1-										<NOP>
	anoremenu PopUp.Goto\ Definition	<cmd>Telescope lsp_definitions<cr>
	anoremenu PopUp.Find\ References	<cmd>Telescope lsp_references<cr>
	anoremenu PopUp.Code\ actions			<cmd>lua vim.lsp.buf.code_action()<cr>
	anoremenu PopUp.Rename						<cmd>lua vim.lsp.buf.rename()<cr>
	anoremenu PopUp.Back							<C-t>
]]

local group = vim.api.nvim_create_augroup("nvim_popupmenu", { clear = true })
vim.api.nvim_create_autocmd("MenuPopup", {
	pattern = "*",
	group = group,
	desc = "Custom PopUp Setup",
	callback = function()
		vim.cmd [[
			amenu disable PopUp.Goto\ Definition
			amenu disable PopUp.Find\ References
			amenu disable PopUp.Code\ actions
			amenu disable PopUp.Rename
		]]

		if vim.lsp.get_clients({ bufnr = 0 })[1] then
			vim.cmd [[
				amenu enable PopUp.Goto\ Definition
				amenu enable PopUp.Find\ References
				amenu enable PopUp.Code\ actions
				amenu enable PopUp.Rename
			]]
		end
	end
})
