require("minuet").setup({
	provider = "openai_fim_compatible",

	n_completions = 3,
	context_window = 8000,
	context_ratio = 0.75,
	throttle = 1000,
	debounce = 400,

	virtualtext = {
		auto_show = true,
		auto_trigger_ft = { "*" },
		auto_trigger_ignore_ft = { "markdown", "text" },
		keymap = {
			accept = "<A-y>",
			accept_line = "<A-e>",
			next = "<A-n>",
			prev = "<A-p>",
			dismiss = "<A-d>",
		},
	},

	provider_options = {
		openai_fim_compatible = {
			api_key = "DEEPSEEK_API_KEY",
			name = "deepseek",
			optional = {
				max_tokens = 256,
				top_p = 0.9,
			},
		},
	},
})
