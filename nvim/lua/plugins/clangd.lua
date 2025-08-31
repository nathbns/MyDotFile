return {
	"neovim/nvim-lspconfig",
	opts = {
		servers = {
			clangd = {
				-- 1) binaire
				cmd = { "clangd", "--clang-tidy", "--fallback-style=Google" },
				-- 2) raccourci pour alterner .cpp/.h
				keys = {
					{ "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header" },
				},
			},
		},
		-- on peut garder sourcekit-lsp, mais seulement pour Swift
		setup = {
			sourcekit = function()
				require("lspconfig").sourcekit.setup({ filetypes = { "swift", "objective-c", "objective-cpp" } })
				return true
			end,
		},
	},
}
