return {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
        "nvim-telescope/telescope.nvim",
        "nvim-treesitter",
    },
    opts = {
        workspaces = {
            {
                name = "Zettelkasten",
                path = "/Users/andywang/Library/Mobile Documents/iCloud~md~obsidian/Documents/Zettelkasten",
            },
        },

        notes_subdir = "inbox",
        new_notes_location = "notes_subdir",

        -- Customize how note IDs are generated given an optional title.
        ---@param title string|?
        ---@return string
        note_id_func = function(title)
            -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
            -- In this case a note with the title 'My new note' will be given an ID that looks
            -- like '2024-09-15-my-new-note', and therefore the file name '2024-09-25-my-new-note.md'
            local suffix = ""
            if title ~= nil then
                -- If title is given, transform it into valid file name.
                suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", "") --:lower()
            else
                -- If title is nil, just add 4 random uppercase letters to the suffix.
                for _ = 1, 4 do
                    suffix = suffix .. string.char(math.random(65, 90))
                end
            end
            return tostring(os.date("%Y-%m-%d")) .. "-" .. suffix
        end,

        templates = {
            folder = "Templates",
            date_format = "%Y-%m-%d-%a",
            time_format = "%H:%M",
        },
    },
}
