return {
	"danymat/neogen",
	name = "neogen",
	config = function()
		require("neogen").setup({})

		local wk = require("which-key")
		wk.add({
			{ "<leader>cc", ":lua require('neogen').generate()<CR>", desc = "Generate doxygen comments", mode = "n" },
		})
	end,
}
