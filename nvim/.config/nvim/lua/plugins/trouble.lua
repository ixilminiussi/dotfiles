return {
	"folke/trouble.nvim",
	opts = {}, -- for default options, refer to the configuration section for custom setup.
	cmd = "Trouble",
	lazy = false,

	config = function()
		require("trouble").setup()

		local wk = require("which-key")
		wk.add({
			{ "<leader>ts", "<Cmd>Trouble symbols toggle<CR>",     desc = "Trouble symbols view",     mode = "n" },
			{ "<leader>td", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Trouble diagnostics view", mode = "n" },
		})
	end
}
