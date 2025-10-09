return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"clangd",
					"glsl_analyzer",
					"gopls",
					"glslls",
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()

			-- Diagnostic configuration
			vim.diagnostic.config({
				virtual_text = false, -- Optional: Disable inline virtual text
				signs = true,
				underline = true,
				update_in_insert = false, -- Optional: Update diagnostics in insert mode
				severity_sort = true, -- Sort diagnostics by severity
			})

			-- Auto-populate Quickfix list with diagnostics
			vim.api.nvim_create_autocmd("DiagnosticChanged", {
				callback = function()
					vim.diagnostic.setqflist({ open = false }) -- Set diagnostics to Quickfix list
				end,
			})

			lspconfig.lua_ls.setup({
				capabilities = capabilities,
			})
			lspconfig.clangd.setup({
				capabilities = capabilities,
				cmd = {
					"clangd",
					"--clang-tidy",
					"--clang-tidy-checks=*, -modernize-*",
					"--completion-style=detailed",
					"--header-insertion=iwyu",
					"--pch-storage=memory",
					"--suggest-missing-includes",
					"--cross-file-rename",
				},
				on_attach = function(client, bufnr)
					client.server_capabilities.documentFormattingProvider = false -- Disable LSP formatting
					client.server_capabilities.documentRangeFormattingProvider = false
				end,
			})
			lspconfig.glslls.setup({
				cmd = { "/home/ixilminiussi/.local/share/nvim/mason/bin/glslls", "--stdin", "--target-env=vulkan" },
				capabilities = capabilities,
				filetypes = { "glsl", "vert", "frag", "geom", "tesc", "tese", "comp" },
			})
			lspconfig.gopls.setup({
				capabilities = capabilities,
			})

			local wk = require("which-key")

			wk.add({
				{ "?",          vim.lsp.buf.hover,       desc = "Hover action",         mode = "n" },
				{ "<leader>gd", vim.lsp.buf.declaration, desc = "Go to declaration",    mode = "n" },
				{ "<leader>gi", vim.lsp.buf.definition,  desc = "Go to implementation", mode = "n" },
				{ "<leader>ca", vim.lsp.buf.code_action, desc = "Code action",          mode = "n" },
			})
		end,
	},
}
