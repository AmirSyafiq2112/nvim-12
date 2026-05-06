require("mason").setup({
	ui = {
		border = "rounded",
		backdrop = 100,
	},
})

require("mason-tool-installer").setup({
	ensure_installed = {
		-- Lua
		"lua_ls",
		"luacheck",
		"stylua",
		"intelephense",
		"prettier",
		"bacon",
		"bacon-ls",
		"rust-analyzer",
		"marksman",
	},
})
