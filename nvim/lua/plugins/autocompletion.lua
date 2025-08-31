-- ~/.config/nvim/lua/plugins/autocompletion.lua
return {
	"hrsh7th/nvim-cmp",

	-------------------------------------------------------------------------- --
	-- Dépendances
	-------------------------------------------------------------------------- --
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			build = (function()
				if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
					return
				end
				return "make install_jsregexp"
			end)(),
			dependencies = {
				{
					"rafamadriz/friendly-snippets",
					config = function()
						require("luasnip.loaders.from_vscode").lazy_load()
					end,
				},
			},
		},
		"saadparwaiz1/cmp_luasnip",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",

		------------------------------------------------------------------ Copilot
		--[[{
			"zbirenbaum/copilot.lua",
			cmd = "Copilot",
			build = ":Copilot auth",
			event = "InsertEnter",
			opts = function()
				local state = vim.fn.stdpath("state") .. "/copilot_enabled"
				local enabled = vim.fn.filereadable(state) == 1 and (vim.fn.readfile(state)[1] == "1") or true
				return {
					suggestion = { enabled = true, auto_trigger = enabled, accept = false },
					panel = { enabled = false },
				}
			end,
			config = function(_, opts)
				require("copilot").setup(opts)
				vim.g.copilot_auto_trigger = opts.suggestion.auto_trigger
			end,
		},
		{
			"zbirenbaum/copilot-cmp",
			dependencies = { "zbirenbaum/copilot.lua" },
			config = function()
				require("copilot_cmp").setup()
			end,
		},]]
		--
	},

	-------------------------------------------------------------------------- --
	-- Configuration principale
	-------------------------------------------------------------------------- --
	config = function()
		local cmp, luasnip = require("cmp"), require("luasnip")
		luasnip.config.setup({})

		------------------------------------------------------------------ État Copilot
		local statefile = vim.fn.stdpath("state") .. "/copilot_enabled"
		local function save_state(v)
			vim.fn.writefile({ v and "1" or "0" }, statefile)
		end
		local function load_state()
			return vim.fn.filereadable(statefile) == 1 and (vim.fn.readfile(statefile)[1] == "1") or true
		end
		vim.g.copilot_auto_trigger = load_state()

		local has_copilot, copilot_s = pcall(require, "copilot.suggestion")

		------------------------------------------------------------------ Helper pour (dé)activer Copilot
		local function apply_copilot_state()
			local enable = vim.g.copilot_auto_trigger

			-- ghost-text Copilot
			if has_copilot then
				if enable then
					vim.cmd("Copilot enable")
				else
					vim.cmd("Copilot disable")
					copilot_s.dismiss()
				end
			end

			-- Sources pour nvim-cmp
			local src = {
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
			}
			if enable then
				table.insert(src, 1, { name = "copilot" })
			end

			cmp.setup({ sources = src })
			cmp.setup.buffer({}) -- applique au buffer courant
			if not enable and cmp.visible() then
				cmp.close()
			end
		end

		------------------------------------------------------------------ Toggle global Copilot
		vim.keymap.set("n", "<leader>ca", function()
			vim.g.copilot_auto_trigger = not vim.g.copilot_auto_trigger
			save_state(vim.g.copilot_auto_trigger)
			apply_copilot_state()
			vim.notify("Copilot completions " .. (vim.g.copilot_auto_trigger and "ENABLED" or "DISABLED"))
		end, { desc = "Toggle Copilot completions (global)" })

		------------------------------------------------------------------ Autocmd pour appliquer état Copilot sur chaque buffer
		vim.api.nvim_create_autocmd(
			{ "BufEnter", "BufNewFile", "BufReadPost", "LspAttach" },
			{ callback = apply_copilot_state }
		)

		------------------------------------------------------------------ nvim-cmp configure
		local icons = {
			Text = "󰉿",
			Method = "m",
			Function = "󰊕",
			Constructor = "",
			Field = "",
			Variable = "󰆧",
			Class = "󰌗",
			Interface = "",
			Module = "",
			Property = "",
			Unit = "",
			Value = "󰎠",
			Enum = "",
			Keyword = "󰌋",
			Snippet = "",
			Color = "󰏘",
			File = "󰈙",
			Reference = "",
			Folder = "󰉋",
			EnumMember = "",
			Constant = "󰇽",
			Struct = "",
			Event = "",
			Operator = "󰆕",
			TypeParameter = "󰊄",
		}

		cmp.setup({
			completion = { completeopt = "menu,menuone,noinsert" },

			-- ── Fenêtres de complétion & de documentation ───────────────────────────
			window = {
				-- encadré pour la liste de complétion
				completion = cmp.config.window.bordered(),
				-- encadré pour le float de documentation (signature + docstring)
				documentation = cmp.config.window.bordered(),
			},

			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},

			mapping = cmp.mapping.preset.insert({
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-Space>"] = cmp.mapping.complete({}),

				["<Tab>"] = cmp.mapping(function(fallback)
					if has_copilot and copilot_s.is_visible() then
						copilot_s.accept()
					elseif cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_locally_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end, { "i", "s" }),

				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),

				-- Optionnel : <C-h> ouvre le float de documentation manuellement
				["<C-h>"] = cmp.mapping(function()
					if cmp.visible() then
						cmp.open_docs()
					else
						vim.lsp.buf.hover()
					end
				end, { "i", "s" }),
			}),

			-- ── Sources initiales (copilot, LSP, LuaSnip, buffer, path) ────────────────
			sources = {
				{ name = "nvim_lsp" },
				{ name = "copilot" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
			},

			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(entry, item)
					item.kind = icons[item.kind] or item.kind
					item.menu = ({
						copilot = "[]",
						nvim_lsp = "[LSP]",
						luasnip = "[Snip]",
						buffer = "[Buf]",
						path = "[Path]",
					})[entry.source.name]
					return item
				end,
			},
		})

		-- Applique l’état initial Copilot sur tous les buffers ouverts
		apply_copilot_state()
	end,
}
