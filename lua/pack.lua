vim.pack.add({
    -- mini
    { src = "https://github.com/nvim-mini/mini.pick" },
    { src = "https://github.com/nvim-mini/mini.icons" },
    { src = "https://github.com/nvim-mini/mini.completion" },
    { src = "https://github.com/nvim-mini/mini.pairs" },
    { src = "https://github.com/nvim-mini/mini.surround" },

    { src = "https://github.com/mbbill/undotree" },

    -- LSP
    { src = "https://github.com/neovim/nvim-lspconfig" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },

    -- folding
    { src = "https://github.com/kevinhwang91/nvim-ufo" },   --enabled
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

    { src = "https://github.com/wansmer/treesj" },
    { src = "https://github.com/abecodes/tabout.nvim" },

    { src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
})

require("mason").setup()
require("mason-lspconfig").setup()
require("fidget").setup()
require("theme.mini-pick-matte")
require("render-markdown").setup()
require("treesj").setup()
require("tabout").setup()
require("ibl").setup({
    indent = {
        char = "┊",
        -- char = "│",
    },
})
-- require("markdown-preview").setup()
