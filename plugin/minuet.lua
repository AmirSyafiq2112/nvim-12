require("minuet").setup({
	enabled = false,
	provider = "openai_fim_compatible",

	n_completions = 3,
	context_window = 8000,
	context_ratio = 0.75,
	throttle = 1000,
	debounce = 600,

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
		openai_compatible = {
			api_key = "OPENCODE_GO_API_KEY",
			end_point = "https://opencode.ai/zen/go/v1/chat/completions",
			model = "deepseek-v4-flash",
			name = "Opencode",
			optional = {
				max_tokens = 56,
				top_p = 0.9,
				-- disable thinking to avoid first token latency
				thinking = { type = "disabled" },
			},
		},
		openai_fim_compatible = {
			api_key = "DEEPSEEK_API_KEY",
			name = "deepseek",
			optional = {
				max_tokens = 256,
				top_p = 0.9,
			},
		},
		openai = {
			api_key = "OPENAI_API_KEY",
			name = "openai",
			optional = {
				max_tokens = 256,
				top_p = 0.9,
			},
		},
	},
})
