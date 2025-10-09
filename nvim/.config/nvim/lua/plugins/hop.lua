return {
	"phaazon/hop.nvim",
	branch = "v2", -- optional but strongly recommended

	config = function()
		require("hop").setup({ keys = "etovxqpdygfblzhckisuran" })

		local wk = require("which-key")
		wk.add({
			{ "fw", "<Cmd>HopWord<CR>",    desc = "Hop to any word",      mode = { "n", "v" } },
			{ "fc", "<Cmd>HopChar1<CR>",   desc = "Hop to any character", mode = { "n", "v" } },
			{ "fp", "<Cmd>HopPattern<CR>", desc = "Hop to any pattern",   mode = { "n", "v" } },
		})
	end,
}
