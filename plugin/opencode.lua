---@type opencode.Opts
vim.g.opencode_opts = {
	-- Your configuration, if any; goto definition on the type for details
}

-- OpenCode Neovim integration settings live here.

vim.o.autoread = true -- Required for `vim.g.opencode_opts.events.reload`

-- Source event handlers from subdirectories (not auto-loaded by Neovim)
-- vim.cmd("runtime plugin/events/reload.lua")
-- vim.cmd("runtime plugin/events/status.lua")
-- vim.cmd("runtime plugin/events/permissions/init.lua")
-- vim.cmd("runtime plugin/events/permissions/edits.lua")

-- Recommended/example keymaps
vim.keymap.set({ "n", "x" }, "<leader>oa", function()
	require("opencode").ask("@this: ")
end, { desc = "Ask OpenCode…" })
vim.keymap.set({ "n", "x" }, "<leader>os", function()
	require("opencode").select()
end, { desc = "Select OpenCode…" })

vim.keymap.set({ "n", "x" }, "go", function()
	return require("opencode").operator("@this ")
end, { desc = "Append range to OpenCode", expr = true })
vim.keymap.set("n", "goo", function()
	return require("opencode").operator("@this ") .. "_"
end, { desc = "Append line to OpenCode", expr = true })

vim.keymap.set("n", "<S-C-u>", function()
	require("opencode").command("session.half.page.up")
end, { desc = "Scroll OpenCode up" })
vim.keymap.set("n", "<S-C-d>", function()
	require("opencode").command("session.half.page.down")
end, { desc = "Scroll OpenCode down" })
