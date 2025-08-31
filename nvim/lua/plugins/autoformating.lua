-- ~/.config/nvim/lua/plugins/autoformatting.lua
return {
	-- 1) Null-LS pour les formateurs génériques
	{
		"nvimtools/none-ls.nvim",
		dependencies = {
			"nvimtools/none-ls-extras.nvim",
			"jayp0521/mason-null-ls.nvim",
		},
		config = function()
			local null_ls = require("null-ls")
			local formatting = null_ls.builtins.formatting

			require("mason-null-ls").setup({
				ensure_installed = {
					"prettier",
					"stylua",
					"eslint_d",
					"shfmt",
					"checkmake",
					"ruff",
					"goimports",
					"gofumpt",
					"golines",
					"terraform_fmt",
					--"swiftlint",
				},
				automatic_installation = true,
			})

			local sources = {
				formatting.prettier.with({ filetypes = { "html", "json", "yaml", "markdown" } }),
				formatting.stylua,
				formatting.shfmt.with({ args = { "-i", "4" } }),
				formatting.terraform_fmt,
				require("none-ls.formatting.ruff").with({ extra_args = { "--extend-select", "I" } }),
				require("none-ls.formatting.ruff_format"),
			}

			local aug = vim.api.nvim_create_augroup("LspFormatting", {})
			null_ls.setup({
				sources = sources,
				on_attach = function(client, bufnr)
					if client.supports_method("textDocument/formatting") then
						vim.api.nvim_clear_autocmds({ group = aug, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = aug,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ bufnr = bufnr, async = false })
							end,
						})
					end
				end,
			})
		end,
	},

	-- 2) rust-tools + rust-analyzer pour Rust
	{
		"simrat39/rust-tools.nvim",
		dependencies = {
			"neovim/nvim-lspconfig",
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		config = function()
			-- 2.1) Mason installe rust-analyzer
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = { "rust_analyzer" },
				automatic_enable = true,
			})

			-- 2.2) rust-tools setup + auto-format sur save
			local rt = require("rust-tools")
			local rust_fmt_grp = vim.api.nvim_create_augroup("RustFmt", {})

			rt.setup({
				server = {
					on_attach = function(_, bufnr)
						vim.api.nvim_clear_autocmds({ group = rust_fmt_grp, buffer = bufnr })
						vim.api.nvim_create_autocmd("BufWritePre", {
							group = rust_fmt_grp,
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ bufnr = bufnr, async = false })
							end,
						})
					end,
				},
			})
		end,
	},
}
