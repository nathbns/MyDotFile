return {
    "folke/tokyonight.nvim", -- ← plugin remplacé
    priority = 1000,
    config = function()
        -- Lua
        require("tokyonight").setup({
            -- Main options --
            style = "night", -- équivalent sombre du "darker" d’OneDark
            transparent = false, -- Show/hide background
            term_colors = true, -- Change terminal color as per the selected theme style
            ending_tildes = false, -- Show the end-of-buffer tildes (Tokyonight les garde)
            cmp_itemkind_reverse = false,

            -- toggle theme style ---
            toggle_style_key = nil, -- Tokyonight n’en tient pas compte, conservé pour la forme
            toggle_style_list = { "night", "storm", "moon", "day" },

            -- Change code style ---
            code_style = {
                comments = "italic",
                keywords = "none",
                functions = "none",
                strings = "none",
                variables = "none",
            },

            -- Lualine options --
            lualine = {
                transparent = false,
            },

            -- Custom Highlights --
            colors = {},
            highlights = {},

            -- Plugins Config --
            diagnostics = {
                darker = true,
                undercurl = true,
                background = true,
            },
        })

        -- charge la palette choisie
        vim.cmd.colorscheme("tokyonight-night")
    end,
}
