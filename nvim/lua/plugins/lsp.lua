-- ~/.config/nvim/lua/plugins/lsp.lua

-- LSP Plugins
return {
	{
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			{ "j-hui/fidget.nvim", opts = {} },
			"saghen/blink.cmp",
		},
		config = function()
			------------------------------------------------------------------------
			-- 1. LSP : au moment où un serveur se connecte à un buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
					map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
					map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
					map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
					map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
					map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
					map("grt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

					local function client_supports_method(client, method, bufnr)
						return client:supports_method(method, bufnr)
					end

					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if
						client
						and client_supports_method(
							client,
							vim.lsp.protocol.Methods.textDocument_documentHighlight,
							event.buf
						)
					then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})
						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})
						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					if
						client
						and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf)
					then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			------------------------------------------------------------------------
			-- 2. Configuration générale des diagnostics
			vim.diagnostic.config({
				severity_sort = true,
				float = { border = "rounded", source = "if_many" },
				underline = { severity = vim.diagnostic.severity.ERROR },
				signs = vim.g.have_nerd_font and {
					text = {
						[vim.diagnostic.severity.ERROR] = "󰅚 ",
						[vim.diagnostic.severity.WARN] = "󰀪 ",
						[vim.diagnostic.severity.INFO] = "󰋽 ",

					},
				} or {},
				virtual_text = {
					source = "if_many",
					spacing = 2,
					format = function(diagnostic)
						return diagnostic.message
					end,
				},
			})

			------------------------------------------------------------------------
			-- 3. Récupération des capabilities (pour cmp) via blink.cmp
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			------------------------------------------------------------------------
			-- 4. Définition de chaque serveur LSP
			local servers = {
				-- Rust (exemple)
				rust_analyzer = {},

				-- TS / JS / React / Electron
				--	tsserver = {
				--	cmd = { "typescript-language-server", "--stdio" },
				--	filetypes = {
				--		"javascript",
				--		"javascriptreact",
				--		"javascript.jsx",
				--		"typescript",
				--		"typescriptreact",
				--		"typescript.tsx",
				--	},
				--	settings = {
				--		completions = { completeFunctionCalls = true },
				--	},
				--	capabilities = {
				--		documentFormattingProvider = false,
				--	},
				-- },

				-- ESLint : lint & fix à la volée
				-- eslint = {
				--	settings = {
				--		workingDirectory = { mode = "auto" },
				--	},
			    --},

				-- Lua (Neovim)
				lua_ls = {
					settings = {
						Lua = {
							completion = { callSnippet = "Replace" },
						},
					},
				},

				-- Tailwind CSS LSP
				tailwindcss = {
					filetypes = {
						"html",
						"css",
						"scss",
						"javascript",
						"javascriptreact",
						"typescript",
						"typescriptreact",
						"tsx",
						"vue",
						"svelte",
					},
					root_dir = require("lspconfig").util.root_pattern(
						"tailwind.config.js",
						"postcss.config.js",
						"package.json",
						".git"
					),
					settings = {
						tailwindCSS = {
							experimental = { classRegex = { "cva\\(([^)]*)\\)" } },
							validate = true,
							lint = {
								cssConflict = "warning",
								invalidApply = "error",
								invalidVariant = "error",
								invalidScreen = "error",
							},
						},
					},
				},

				-- HTML & CSS (pour compléter IntelliSense, Emmet, etc.)
				html = {},
				cssls = {},
			}

			------------------------------------------------------------------------
			-- 5. Liste des outils à installer via Mason
			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				"stylua", -- formateur Lua
				-- "prettierd", -- formateur JS/TS
				-- "eslint_d", -- lint JS/TS
				"tailwindcss-language-server",
				"html-lsp",
				"css-lsp",
			})
			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			------------------------------------------------------------------------
			-- 6. Installation/Configuration automatique des LSP via mason-lspconfig
			require("mason-lspconfig").setup({
				ensure_installed = {},
				automatic_installation = false,
				handlers = {
					function(server_name)
						local server_opts = servers[server_name] or {}
						server_opts.capabilities =
							vim.tbl_deep_extend("force", {}, capabilities, server_opts.capabilities or {})
						require("lspconfig")[server_name].setup(server_opts)
					end,
				},
			})
		end,
	},

	------------------------------------------------------------------------
	-- 7. null-ls : formatting / linting (Prettier + ESLint_d)
	{
		"nvimtools/none-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { "mason-org/mason.nvim" },
		config = function()
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- null_ls.builtins.formatting.prettierd,
					-- null_ls.builtins.diagnostics.eslint_d,
					-- null_ls.builtins.code_actions.eslint_d,
				},
			})
		end,
	},
}
