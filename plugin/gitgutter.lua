-- This file runs at startup. It just wires up the user command.
-- The actual setup() must be called by the user in their config.

vim.api.nvim_create_user_command("GitGutterUpdate", function()
    require("gitgutter").update()
end, { desc = "Manually refresh git gutter signs" })

vim.api.nvim_create_user_command("GitGutterToggle", function()
    local gg = require("gitgutter")
    gg.config.enabled = not gg.config.enabled
    if not gg.config.enabled then
        require("gitgutter.signs").clear(vim.api.nvim_get_current_buf())
    else
        gg.update()
    end
end, { desc = "Toggle git gutter signs" })
