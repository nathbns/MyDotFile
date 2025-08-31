-- ~/.config/nvim/lua/plugins/rust.lua
return {
	"simrat39/rust-tools.nvim",
	dependencies = {
		"neovim/nvim-lspconfig",
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		require("mason").setup()
		require("mason-lspconfig").setup({ ensure_installed = { "rust_analyzer" } })

		local rt = require("rust-tools")
		local augroup = vim.api.nvim_create_augroup("RustFmt", {})

		rt.setup({
			server = {
				on_attach = function(_, bufnr)
					vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ bufnr = bufnr, async = false })
						end,
					})
				end,
			},
		})
	end,
}
