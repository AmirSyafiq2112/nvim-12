local treesitter = require("nvim-treesitter")

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
	"markdown",
	"jsx",
	"typescript",
	"tsx",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua", "rust", "javascript", "jsx", "zig", "typescript", "typescriptreact" },
	callback = function()
		-- syntax highlighting, provided by Neovim
		vim.treesitter.start()
		-- folds, provided by Neovim
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.wo.foldmethod = "expr"
		-- indentation, provided by nvim-treesitter
		-- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})
