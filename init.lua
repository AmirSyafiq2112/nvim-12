require("vim._core.ui2").enable({
	enable = true,
	msg = {
		target = "cmd",
		pager = { height = 0.5 },
		dialog = { height = 0.5 },
		cmd = { height = 0.5 },
		msg = { height = 0.5, timeout = 4500 },
	},
})

require("pack")
require("core")

vim.diagnostic.config({
	virtual_text = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
	end,
})

-- require("gitgutter").setup({
--     signs = {
--         add = { color = "#32CD32" },
--         delete = { color = "#FF5555" },
--         change = { color = "#ffff00" },
--     },
-- })
