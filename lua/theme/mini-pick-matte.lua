-- Create augroup (prevents duplicates on reload)
local group = vim.api.nvim_create_augroup("MiniPickMatteblack", { clear = true })

-- Apply when matteblack is loaded
vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  pattern = "matteblack",
  callback = function()
    -- GLOBAL (affects all floating windows)
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#f88300", bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatTitle", { bg = "NONE", bold = true })

    -- Remove shadow (your “gray padding” issue)
    vim.api.nvim_set_hl(0, "FloatShadow", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "FloatShadowThrough", { bg = "NONE" })

    -- MINI.PICK SPECIFIC
    vim.api.nvim_set_hl(0, "MiniPickNormal", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "MiniPickMatchCurrent", {
      bg = "#b25e00",
      bold = true,
    })
    vim.api.nvim_set_hl(0, "MiniPickPrompt", {
      bg = "NONE",
      bold = true,
    })
  end,
})

-- If colorscheme already loaded before this file runs
if vim.g.colors_name == "matteblack" then
  vim.cmd("doautocmd ColorScheme matteblack")
end
