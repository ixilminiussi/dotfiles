return {
	"nvim-treesitter/nvim-treesitter",
	name = "treesitter",
	build = ":TSUpdate",

	-- run early; may run before the plugin is loaded
	init = function()
		local parser = {
			install_info = {
				url = "https://github.com/constantitus/tree-sitter-jai",
				files = { "src/parser.c", "src/scanner.c" },
			},
			filetype = "jai",
		}

		-- try to register now; if treesitter isn't available yet, stash it
		local ok, parsers_mod = pcall(require, "nvim-treesitter.parsers")
		if ok and parsers_mod and parsers_mod.get_parser_configs then
			local parser_config = parsers_mod.get_parser_configs()
			parser_config.jai = parser
		else
			vim.g._custom_treesitter_parsers = vim.g._custom_treesitter_parsers or {}
			vim.g._custom_treesitter_parsers.jai = parser
		end
	end,

	config = function()
		-- if we stashed configs earlier, apply them now
		if vim.g._custom_treesitter_parsers then
			local ok, parsers_mod = pcall(require, "nvim-treesitter.parsers")
			if ok and parsers_mod and parsers_mod.get_parser_configs then
				local parser_config = parsers_mod.get_parser_configs()
				for name, cfg in pairs(vim.g._custom_treesitter_parsers) do
					parser_config[name] = cfg
				end
			end
			vim.g._custom_treesitter_parsers = nil
		end

		require("nvim-treesitter.configs").setup({
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
