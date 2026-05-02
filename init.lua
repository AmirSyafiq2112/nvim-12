require("vim._core.ui2").enable({
    enable = true,
    msg = {
        target = "cmd",
        pager = { height = 0.5 },
        dialog = { height = 0.5 },
        cmd = { height = 0.5 },
        msg = { height = 0.5, timeout = 4500 },
    },
})

require("pack")
require("core")

vim.diagnostic.config({
    virtual_text = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local c = vim.lsp.get_client_by_id(args.data.client_id)
        if not c then
            return
        end

        if vim.bo.filetype == "lua" then
            -- Format the current buffer on save
            vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = args.buf,
                callback = function()
                    vim.lsp.buf.format({ bufnr = args.buf, id = c.id })
                end,
            })
        end
    end,
})
