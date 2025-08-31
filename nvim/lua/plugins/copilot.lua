-- ~/.config/nvim/lua/plugins/copilot.lua
return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		event = "InsertEnter",
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				accept = false, -- on désactive le mapping <Tab> interne
			},
			panel = { enabled = false },
		},
		config = function(_, opts)
			require("copilot").setup(opts)

			-- variable globale pour suivre l'état
			local copilot_enabled = true

			-- fonction pour toggle
			local function toggle_copilot()
				copilot_enabled = not copilot_enabled
				if copilot_enabled then
					vim.cmd("Copilot enable")
					vim.notify("Copilot activé", vim.log.levels.INFO)
				else
					vim.cmd("Copilot disable")
					vim.notify("Copilot désactivé", vim.log.levels.WARN)
				end
			end

			vim.keymap.set("n", "<leader>cc", toggle_copilot, { desc = "Toggle Copilot" })
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		dependencies = "zbirenbaum/copilot.lua",
		config = function()
			require("copilot_cmp").setup()
		end,
	},
}
