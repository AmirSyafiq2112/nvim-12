local M = {}

function M.apply()
	-- vim.api.nvim_set_hl(0, "DiffAdd", { fg = "#a3be8c", bg = "#263528" })
	-- vim.api.nvim_set_hl(0, "DiffChange", { fg = "#ebcb8b", bg = "#34322a" })
	-- vim.api.nvim_set_hl(0, "DiffDelete", { fg = "#bf616a", bg = "#3b262b" })
	-- vim.api.nvim_set_hl(0, "DiffText", { fg = "#eceff4", bg = "#4c566a", bold = true })

	vim.api.nvim_set_hl(0, "GitSignsAdd", { fg = "#a3be8c" })
	vim.api.nvim_set_hl(0, "GitSignsChange", { fg = "#ebcb8b" })
	vim.api.nvim_set_hl(0, "GitSignsDelete", { fg = "#bf616a" })
	vim.api.nvim_set_hl(0, "GitSignsAddLn", { link = "DiffAdd" })
	vim.api.nvim_set_hl(0, "GitSignsChangeLn", { link = "DiffChange" })
	vim.api.nvim_set_hl(0, "GitSignsDeleteLn", { link = "DiffDelete" })

	vim.api.nvim_set_hl(0, "NeogitDiffAdd", { fg = "#a3be8c", bg = "#263528" })
	vim.api.nvim_set_hl(0, "NeogitDiffAddHighlight", { fg = "#d8dee9", bg = "#263528" })
	vim.api.nvim_set_hl(0, "NeogitDiffAddInline", { fg = "#eceff4", bg = "#3f5f35", bold = true })
	vim.api.nvim_set_hl(0, "NeogitDiffDelete", { fg = "#bf616a", bg = "#3b262b" })
	vim.api.nvim_set_hl(0, "NeogitDiffDeleteHighlight", { fg = "#d8dee9", bg = "#3b262b" })
	vim.api.nvim_set_hl(0, "NeogitDiffDeleteInline", { fg = "#eceff4", bg = "#7a3440", bold = true })
end

return M
