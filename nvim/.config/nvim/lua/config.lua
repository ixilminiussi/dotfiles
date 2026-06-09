vim.g.mapleader = " "

vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set smarttab")
vim.cmd("set smoothscroll")

vim.opt.number = true
vim.wo.relativenumber = true

vim.filetype.add({
	extension = {
		vert = "glsl",
		frag = "glsl",
		jai = "jai",
	},
})

-- Function to preserve both cursor and scroll position
local function format_and_preserve_view()
	local pos = vim.api.nvim_win_get_cursor(0) -- Save the current cursor position
	local view = vim.fn.winsaveview()       -- Save the current view (scroll position)
	vim.lsp.buf.format()                    -- Format the document
	vim.api.nvim_win_set_cursor(0, pos)     -- Restore the cursor position
	vim.fn.winrestview(view)                -- Restore the scroll position
end

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*",                    -- For all file types
	callback = format_and_preserve_view, -- Reference the Lua function here
})
