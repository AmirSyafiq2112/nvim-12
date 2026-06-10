local minipick = require("mini.pick")

local win_config = function()
	local height = math.floor(0.618 * vim.o.lines)
	local width = math.floor(0.618 * vim.o.columns)
	return {
		anchor = "NW",
		height = height,
		width = width,
		row = math.floor(0.5 * (vim.o.lines - height)),
		col = math.floor(0.5 * (vim.o.columns - width)),
		border = "rounded",
	}
end

minipick.setup({
	window = {
		config = win_config,
	},
})

-- mini icon
require("mini.icons").setup()
-- NOTE: Completion is handled by blink.cmp in lua/pack.lua.
-- Keeping mini.completion disabled avoids keymap/behavior conflicts.
require("mini.pairs").setup()
require("mini.surround").setup()

local indentscope = require("mini.indentscope")

indentscope.setup({
	symbol = "│",
	draw = {
		animation = indentscope.gen_animation.none(),
	},
})
