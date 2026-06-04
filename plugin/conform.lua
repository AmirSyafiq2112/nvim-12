local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		-- rust = { "rustfmt", lsp_format = "fallback" },
		-- Conform will run the first available formatter
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		php = { "intelephense" },
	},
	default_format_opts = {
		lsp_format = "fallback",
	},
	format_on_save = {
		lsp_format = "fallback",
		timeout_ms = 500,
	},
	notify_on_error = true,
})

vim.keymap.set("n", "<leader>fe", function()
	conform.format()
end, { desc = "[F]ormat [E]ditor" })
