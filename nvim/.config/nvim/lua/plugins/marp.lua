return {
	"mpas/marp-nvim",
	name = "marp-nvim",

	config = function()
		require("marp").setup({
			port = 8080,
			wait_for_response_timeout = 30,
			wait_for_response_delay = 1,
		})

		local wk = require("which-key")
		wk.add({
			{
				"<leader>mt",
				"<cmd>MarpToggle<cr>",
				desc = "Marp toggle",
				mode = "n",
			},
			{
				"<leader>ms",
				"<cmd>MarpStatus<cr>",
				desc = "Marp status",
				mode = "n",
			},
		})
	end,
}
