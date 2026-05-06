local treesitter = require("nvim-treesitter")
local config = require("nvim-treesitter.config")

treesitter.setup({
    ensure_installed = {
        "vim",
        "vimdoc",
        "rust",
        "lua",
        "html",
        "css",
        "javacsript",
        "json",
        "php",
        "markdown",
    },
})
