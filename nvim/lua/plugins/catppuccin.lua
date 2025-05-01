return {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    lazy = false,
    config = function()
        require('catppuccin').setup {
            transparent_background = true,
            styles = {           -- Handles the styles of general hi groups (see `:h highlight-args`):
                comments = { 'italic' }, -- Change the style of comments
                conditionals = { 'bold' },
                loops = { 'bold' },
                functions = {},
                keywords = { 'bold' },
                strings = {},
                variables = {},
                numbers = {},
                booleans = {},
                properties = {},
                types = {},
                operators = {},
                -- miscs = {}, -- Uncomment to turn off hard-coded styles
            },
            integrations = {
                cmp = true,
                gitsigns = true,
                nvimtree = true,
                treesitter = true,
            },
            custom_highlights = function(colors)
                return {
                    Comment = { fg = colors.overlay2 },
                    LineNr = { fg = colors.overlay2 },
                    NeoTreeMessage = { fg = colors.overlay2 },
                    NeoTreeFileStats = { fg = colors.overlay2 },
                    NeoTreeFileStatsHeader = { fg = colors.blue },
                    --NvimDapVirtualText = {fg = colors.sky },
                    --NotifyBackground = { fg = colors.blue },
                }
            end,
        }
        vim.cmd.colorscheme 'catppuccin-frappe'
    end,
}
