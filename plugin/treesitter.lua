local treesitter = require("nvim-treesitter")

vim.filetype.add({
	pattern = {
		[".*%.blade%.php"] = "blade",
	},
})

treesitter.install({
	"vim",
	"vimdoc",
	"rust",
	"lua",
	"html",
	"css",
	"javascript",
	"json",
	"php",
	"blade",
	"markdown",
	"jsx",
	"typescript",
	"tsx",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua", "rust", "javascript", "jsx", "zig", "typescript", "typescriptreact", "php", "blade" },
	callback = function()
		-- Avoid hard errors when parser is not installed yet.
		local ok = pcall(vim.treesitter.start)

		if ok then
			-- folds, provided by Neovim
			vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.wo.foldmethod = "expr"
		elseif vim.bo.filetype == "blade" then
			-- Fallback highlight until the Blade parser finishes installing.
			vim.bo.syntax = "php"
		end
		-- indentation, provided by nvim-treesitter
		-- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
