require("mason").setup({
	ui = {
		border = "rounded",
		backdrop = 100,
	},
})

require("mason-tool-installer").setup({
	ensure_installed = {
		--general
		"prettier",
		"prettierd",

		-- lua
		"lua_ls",
		"luacheck",
		"stylua",

		-- php
		"intelephense",
		"blade-formatter",

		-- rust
		"bacon",
		"bacon-ls",
		"rust-analyzer",
		"marksman",

		-- typescript
		"vtsls",
		-- "ts_ls",
		"eslint",
	},
})
