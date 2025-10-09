local wk = require("which-key")

local map = vim.api.nvim_set_keymap

map("", "<Up>", "<Nop>", { noremap = true })
map("", "<Left>", "<Nop>", { noremap = true })
map("", "<Right>", "<Nop>", { noremap = true })
map("", "<Down>", "<Nop>", { noremap = true })

wk.add({
	{ "<S-h>", "<C-w>h",                   desc = "Shift to left window",          mode = "n" },
	{ "<S-j>", "<C-w>j",                   desc = "Shift to bottom window",        mode = "n" },
	{ "<S-k>", "<C-w>k",                   desc = "Shift to up window",            mode = "n" },
	{ "<S-l>", "<C-w>l",                   desc = "Shift to right window",         mode = "n" },
	{ "|",     "<C-w>v",                   desc = "Split window vertically",       mode = "n" },
	{ "_",     "<C-w>s",                   desc = "Split window horizontally",     mode = "n" },
	{ "<S-q>", "[[:lua SaveAndQuit()<CR>", desc = "Save and close current window", mode = "n" },
})

function SaveAndQuit()
	pcall(vim.cmd, "w")
	vim.cmd("exit!")
end
