local lang_utils = require("treesj.langs.utils")

require("treesj").setup({
	langs = {
		-- blade inherits html structure from tree-sitter-blade v0.12+
		-- Run :InspectTree in a .blade.php file to see exact node names
		blade = {
			-- HTML element attributes: class="a b" -> multiline
			attribute = lang_utils.set_preset_for_args({
				both = {
					separator = " ",
					last_separator = false,
				},
			}),

			-- <div ...> opening tag attributes list
			start_tag = lang_utils.set_preset_for_args({
				both = {
					separator = " ",
					last_separator = false,
				},
			}),

			-- Self-closing tags: <input ... />
			self_closing_tag = lang_utils.set_preset_for_args({
				both = {
					separator = " ",
					last_separator = false,
				},
			}),

			-- HTML element (the whole node: tag + children + closing tag)
			element = lang_utils.set_preset_for_statement(),

			-- Quoted attribute values: class="foo bar baz"
			quoted_attribute_value = lang_utils.set_preset_for_list({
				both = {
					separator = " ",
					last_separator = false,
				},
			}),

			-- PHP/Blade expressions inside {{ }} or {!! !!}
			-- These show up as "escaped_echo_statement" or "unescaped_echo_statement"
			escaped_echo_statement = lang_utils.set_preset_for_statement(),
			unescaped_echo_statement = lang_utils.set_preset_for_statement(),

			-- Blade directive blocks: @if / @foreach / etc.
			if_statement = lang_utils.set_preset_for_statement(),
			for_statement = lang_utils.set_preset_for_statement(),
			foreach_statement = lang_utils.set_preset_for_statement(),

			-- PHP array/object literals that appear inside blade expressions
			array_creation_expression = lang_utils.set_preset_for_list(),
			arguments = lang_utils.set_preset_for_args(),
			parameters = lang_utils.set_preset_for_args(),
		},

		-- blade also injects php/html sub-trees; TreeSJ auto-detects those
		-- via its "recognize nested languages" feature, so you get php/html
		-- behaviour for free inside blade files without extra config.
	},
})
