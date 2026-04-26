vim.pack.add({
	-- mini
	{ src = "https://github.com/echasnovski/mini.pick" },
	{ src = "https://github.com/echasnovski/mini.icons" },
	{ src = "https://github.com/echasnovski/mini.completion" },

	{ src = "https://github.com/mbbill/undotree" },

	-- LSP
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },

	-- folding
	{ src = "https://github.com/kevinhwang91/nvim-ufo" }, --enabled
	{ src = "https://github.com/kevinhwang91/promise-async" }, --nvim-ufo dependency

	-- 	oil
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" }, --optional dependency
    { src = "https://github.com/tahayvr/matteblack.nvim" },
})

require("mason").setup()
require("mason-lspconfig").setup()
require"matteblack".colorscheme()
require("theme.mini-pick-matte")

