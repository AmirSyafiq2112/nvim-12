vim.pack.add({
	-- treesitter
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},

	-- completion
	{ src = "https://github.com/saghen/blink.lib" },
	{ src = "https://github.com/saghen/blink.cmp" },

	-- mini
	{ src = "https://github.com/nvim-mini/mini.pick" },
	{ src = "https://github.com/nvim-mini/mini.icons" },
	{ src = "https://github.com/nvim-mini/mini.completion" },
	{ src = "https://github.com/nvim-mini/mini.pairs" },
	{ src = "https://github.com/nvim-mini/mini.surround" },
	{ src = "https://github.com/nvim-mini/mini.indentscope" },

	{ src = "https://github.com/mbbill/undotree" },

	-- LSP
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },

	-- formatter
	{ src = "https://github.com/stevearc/conform.nvim" },

	-- folding
	{ src = "https://github.com/kevinhwang91/nvim-ufo" }, --enabled
	{ src = "https://github.com/kevinhwang91/promise-async" }, --nvim-ufo dependency

	-- 	oil
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" }, --optional dependency
	{ src = "https://github.com/tahayvr/matteblack.nvim" },

	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },

	-- telescope
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim", build = "make", opt = false },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },

	-- folke
	{ src = "https://github.com/folke/flash.nvim" },

	{ src = "https://github.com/j-hui/fidget.nvim" },

	-- markdown
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
	{ src = "https://github.com/iamcco/markdown-preview.nvim" },

	-- html
	{ src = "https://github.com/windwp/nvim-ts-autotag" },

	{ src = "https://github.com/wansmer/treesj" },
	{ src = "https://github.com/abecodes/tabout.nvim" },

	{ src = "https://github.com/lukas-reineke/indent-blankline.nvim" },

	-- git
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/NeogitOrg/neogit" },

	-- ai tools
	{ src = "https://github.com/milanglacier/minuet-ai.nvim" },
	{ src = "https://github.com/lululau/neogit-ai-commit.nvim" },
	{
		src = "https://github.com/nickjvandyke/opencode.nvim",
		version = vim.version.range("*"), -- Latest stable release
	},

	-- colorscheme
	{ src = "https://github.com/shaunsingh/nord.nvim" },

	-- utilities
	{ src = "https://github.com/folke/snacks.nvim" },
})

require("mason").setup()
require("mason-lspconfig").setup()
require("fidget").setup()
require("theme.mini-pick-matte")
require("render-markdown").setup()
require("tabout").setup()
require("nvim-ts-autotag").setup({
	opts = {
		-- Defaults
		enable_close = true, -- Auto close tags
		enable_rename = true, -- Auto rename pairs of tags
		enable_close_on_slash = false, -- Auto close on trailing </
	},
})

require("ibl").setup({
	indent = {
		char = "┊",
		-- char = "│",
	},
	scope = {
		enabled = false,
	},
})

-- require("markdown-preview").setup()
