return {
	"akinsho/toggleterm.nvim",

	config = function()
		require("toggleterm").setup()

		local wk = require("which-key")

		wk.add({
			{ "<A-i>", "<Cmd>ToggleTerm direction=float<CR>",            desc = "Toggles floating terminal",   mode = { "t", "n" } },
			{ "<A-l>", "<Cmd>ToggleTerm size=60 direction=vertical<CR>", desc = "Toggles vertical terminal",   mode = { "t", "n" } },
			{ "<A-j>", "<Cmd>ToggleTerm direction=horizontal<CR>",       desc = "Toggles horizontal terminal", mode = { "t", "n" } },
			{ "<Esc>", "<Cmd>ToggleTerm<CR>",                            desc = "Toggles off terminal",        mode = { "t" } },
		})
	end,
}
