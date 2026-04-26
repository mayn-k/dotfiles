return {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    keys = {
        { "<C-h>", "<cmd>TmuxNavigateLeft<CR>",  desc = "Tmux nav left"  },
        { "<C-j>", "<cmd>TmuxNavigateDown<CR>",  desc = "Tmux nav down"  },
        { "<C-k>", "<cmd>TmuxNavigateUp<CR>",    desc = "Tmux nav up"    },
        { "<C-l>", "<cmd>TmuxNavigateRight<CR>", desc = "Tmux nav right" },
    },
}
