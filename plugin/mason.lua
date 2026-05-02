require("mason").setup({
    ui = {
        border = "rounded",
        backdrop = 100,
    },
})

require("mason-tool-installer").setup({
    ensure_installed = {
        "lua_ls",
        "stylua",
        "intelephense",
        "prettier",
        "bacon",
        "bacon-ls",
        "rust-analyzer",
        "marksman",
    },
})
