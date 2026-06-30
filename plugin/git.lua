-- GitSigns
require("gitsigns").setup({
	current_line_blame_opts = {
		delay = 100,
	},
	on_attach = function()
		local gitsigns = require("gitsigns")

		vim.keymap.set("n", "<leader>gh", gitsigns.preview_hunk, { desc = "[G]it Preview [H]unk" })
		vim.keymap.set("n", "<leader>gi", gitsigns.preview_hunk, { desc = "[G]it Preview [I]nline Hunk" })
		vim.keymap.set("n", "<leader>gb", gitsigns.blame, { desc = "[G]it [B]lame" })
		vim.keymap.set("n", "<leader>gl", gitsigns.blame_line, { desc = "[G]it Blame [L]ine" })
		vim.keymap.set("n", "<leader>tl", gitsigns.toggle_current_line_blame, { desc = "[T]oggle [L]ine Blame" })
	end,
})

-- Neogit
local neogit = require("neogit")

neogit.setup()

vim.keymap.set("n", "<leader>ng", neogit.open, { desc = "Open [N]eo[G]it UI" })

-- Neogit AI Commit
require("neogit-ai-commit").setup({
	api_key = vim.env.DEEPSEEK_API_KEY,
	api_url = "https://api.deepseek.com/v1/chat/completions",
	model = "deepseek-chat",
})

vim.keymap.set("n", "<leader>nac", "<cmd>NeogitAICommit<CR>", { desc = "[N]eogit [A]I [C]ommit" })
