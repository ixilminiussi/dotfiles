return {
	"nvim-neo-tree/neo-tree.nvim",
	name = "neo-tree",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},

	config = function()
		local wk = require("which-key")
		wk.add({
			{ "<leader>e", ":Neotree toggle<CR>", desc = "Toggle Neo-tree", mode = "n" },
		})
	end,
}
