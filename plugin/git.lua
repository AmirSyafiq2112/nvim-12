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
	-- openai_api_key = "sk-b1f731c28f36445aa1ed2a9ff1a5ba5d",
	-- api_url = "https://api.openai.com/v1/chat/completions",
	-- model = "gpt-3.5-turbo",
	api_url = "https://api.deepseek.com/v1/chat/completions",
	model = "deepseek-v4-flash",
})

vim.keymap.set("n", "<leader>nac", "<cmd>NeogitAICommit<CR>", { desc = "[N]eogit [A]I [C]ommit" })
