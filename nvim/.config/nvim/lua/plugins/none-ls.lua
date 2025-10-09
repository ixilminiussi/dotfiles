return {
	"nvimtools/none-ls.nvim",

	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua.with({
					condition = function(utils)
						return utils.root_has_file("stylua.toml")
					end,
				}),
				null_ls.builtins.formatting.prettier.with({
					condition = function(utils)
						return utils.root_has_file(".prettierrc")
					end,
				}),
				null_ls.builtins.formatting.clang_format.with({
					command = "clang-format",
					extra_args = { "-style", "{BasedOnStyle: Microsoft, QualifierAlignment: Right}" },
					filetypes = { "c", "cpp", "cs", "h", "hpp" },
				}),
				null_ls.builtins.formatting.clang_format.with({
					command = "clang-format",
					extra_args = { "-style", "{BasedOnStyle: Microsoft, QualifierAlignment: Left}" },
					filetypes = { "glsl", "vert", "frag", "geom" },
				}),
				null_ls.builtins.formatting.cmake_format.with({
					command = "cmake-format",
					extra_args = {},
					filetypes = { "cmake" },
				}),
				null_ls.builtins.formatting.black.with({
					extra_args = { "--line-length", "88" },
					filetypes = { "python" },
				}),
			},
		})

		-- Function to preserve both cursor and scroll position
		local function format_and_preserve_view()
			local pos = vim.api.nvim_win_get_cursor(0) -- Save the current cursor position
			local view = vim.fn.winsaveview() -- Save the current view (scroll position)
			vim.lsp.buf.format()              -- Format the document
			vim.api.nvim_win_set_cursor(0, pos) -- Restore the cursor position
			vim.fn.winrestview(view)          -- Restore the scroll position
		end

		local wk = require("which-key")
		wk.add({
			{ "<leader>fm", format_and_preserve_view, desc = "Format current file", mode = "n" },
		})
	end,
}
