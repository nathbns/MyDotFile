-- ~/.config/nvim/lua/plugins/swift.lua
return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {}, -- SourceKit-LSP n'est pas géré par Mason
				automatic_installation = true,
			})

			local lspconfig = require("lspconfig")
			local swift_fmt_grp = vim.api.nvim_create_augroup("SwiftFmt", {})

			lspconfig.sourcekit.setup({
				-- si tu as besoin de dynamicRegistration ➜ voir guide :contentReference[oaicite:0]{index=0}
				on_attach = function(_, bufnr)
					-- keymaps Swift…
					vim.api.nvim_buf_set_keymap(
						bufnr,
						"n",
						"gd",
						"<Cmd>lua vim.lsp.buf.definition()<CR>",
						{ silent = true, noremap = true }
					)
					vim.api.nvim_buf_set_keymap(
						bufnr,
						"n",
						"K",
						"<Cmd>lua vim.lsp.buf.hover()<CR>",
						{ silent = true, noremap = true }
					)

					-- format automatique à la sauvegarde
					vim.api.nvim_clear_autocmds({ group = swift_fmt_grp, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = swift_fmt_grp,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ bufnr = bufnr, async = false })
						end,
					})
				end,
			})
		end,
	},
}
