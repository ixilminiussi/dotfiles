return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },

    config = function ()
        require("todo-comments").setup()

        local wk = require("which-key")
        wk.add({
            { "<leader>ft", "<Cmd>TodoTelescope<CR>", desc = "Find TODOs", mode = "n" }
        })
    end
}
