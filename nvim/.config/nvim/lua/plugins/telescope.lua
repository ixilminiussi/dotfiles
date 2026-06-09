return {
	{
		"nvim-telescope/telescope.nvim",
		name = "telescope",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},

		config = function()
			local builtin = require("telescope.builtin")

			local wk = require("which-key")
			wk.add({
				{ "<leader>ff", builtin.find_files, desc = "Fuzzy file find",   mode = "n" },
				{ "<leader>fw", builtin.live_grep,  desc = "Live grep find",    mode = "n" },
				{ "<leader>fr", builtin.oldfiles,   desc = "Find recent files", mode = "n" },
			})
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",

		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
