local ok, copilot = pcall(require, "copilot")

if not ok then
	return
end

copilot.setup({
	panel = {
		enabled = false,
	},
	suggestion = {
		enabled = true,
		auto_trigger = true,
		hide_during_completion = true,
		debounce = 75,
		keymap = {
			accept = "<Tab>",
			accept_word = "<Right>",
			accept_line = false,
			next = "<C-n>",
			prev = "<C-p>",
			dismiss = "<Esc>",
			toggle_auto_trigger = false,
		},
	},
})

local copilot_group = vim.api.nvim_create_augroup("copilot_blink", { clear = true })

vim.api.nvim_create_autocmd("User", {
	group = copilot_group,
	pattern = "BlinkCmpMenuOpen",
	callback = function()
		vim.b.copilot_suggestion_hidden = true
	end,
})

vim.api.nvim_create_autocmd("User", {
	group = copilot_group,
	pattern = "BlinkCmpMenuClose",
	callback = function()
		vim.b.copilot_suggestion_hidden = false
	end,
})
