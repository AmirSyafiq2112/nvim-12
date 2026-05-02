local function get_hl(name)
    return vim.api.nvim_get_hl(0, { name = name, link = false })
end

local normal = get_hl("Normal")
local comment = get_hl("Comment")

vim.api.nvim_set_hl(0, "NormalFloat", {
    bg = normal.bg,
})

vim.api.nvim_set_hl(0, "FloatBorder", {
    bg = normal.bg,
    fg = comment.fg,
})

vim.keymap.set("n", "K", function()
    vim.lsp.buf.hover({
        border = "rounded",
    })
end)
