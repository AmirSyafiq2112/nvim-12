require("blink.cmp").setup({
	keymap = {
		preset = "default",
		["<C-n>"] = { "select_next", "fallback_to_mappings" },
		["<C-p>"] = { "select_prev", "fallback_to_mappings" },
		["<C-y>"] = { "select_and_accept", "fallback" },
		["<A-g>"] = require("minuet").make_blink_map(),
	},
	signature = {
		enabled = false,
	},
	completion = {
		trigger = {
			prefetch_on_insert = false,
		},
	},
	sources = {
		default = { "lsp", "path", "buffer", "snippets", "minuet" },
		providers = {
			minuet = {
				name = "minuet",
				module = "minuet.blink",
				score_offset = 8,
				transform_items = function(items)
					for _, item in ipairs(items) do
						item.label = "✨ " .. item.label
					end
					return items
				end,
			},
		},
	},
})

require("blink.cmp").build():wait(60000)
