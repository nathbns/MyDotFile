-- ~/.config/nvim/lua/plugins/leetcode.lua
return {
	"kawre/leetcode.nvim",
	-- Installe/MAJ la grammaire HTML pour l'énoncé (facultatif)
	-- build = ":TSUpdate html",

	dependencies = {
		-- Picker (prends celui que tu utilises déjà)
		"nvim-telescope/telescope.nvim", -- ou "ibhagwan/fzf-lua"
		-- Libs obligatoires
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},

	opts = {
		-- ========= Personnalisation minimale =========
		lang = "cpp", -- langage par défaut (python3, java…)
		plugins = { -- lance LeetCode dans une fenêtre dédiée
			non_standalone = false, -- true = intégration dans ta session nvim
		},
		-- ======== (optionnel) active le site chinois ========
		-- cn = { enabled = true },
	},
}
