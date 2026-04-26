return {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter.configs").setup({
            ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query",
                                 "javascript", "html", "bash" },
            highlight = { enable = true },
            indent    = { enable = true },
        })
    end,
}
