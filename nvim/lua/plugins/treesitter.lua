-- ~/.config/nvim/lua/plugins/treesitter.lua

return {
	-- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs", -- Sets main module to use for opts

	opts = {
		ensure_installed = {
			"lua",
			"python",
			"javascript",
			"typescript",
			"tsx",
			"vimdoc",
			"vim",
			"regex",
			"terraform",
			"sql",
			"dockerfile",
			"toml",
			"json",
			"java",
			"groovy",
			"go",
			"gitignore",
			"graphql",
			"yaml",
			"make",
			"cmake",
			"markdown",
			"markdown_inline",
			"bash",
			"css",
			"html",
			"rust",
			-- "swift",
		},
		-- Installe automatiquement les parsers manquants
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = { "ruby" },
		},
		indent = {
			enable = true,
			disable = { "ruby" },
		},
		incremental_selection = {
			enable = true,
			keymaps = {
				init_selection = "gnn", -- commence la sélection
				node_incremental = "grn", -- agrandir la sélection au nœud suivant
				scope_incremental = "grc", -- agrandir jusqu’au scope
				node_decremental = "grm", -- réduire la sélection
			},
		},
		-- (Optionnel : tu peux ajouter d’autres modules treesitter ici si besoin)
	},
}
