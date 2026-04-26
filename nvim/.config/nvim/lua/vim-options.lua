-- ~/.config/nvim/lua/vim-options.lua
vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set number relativenumber")
vim.cmd("set guicursor=n-v-c:block-Cursor/lCursor")

vim.g.mapleader = " "

-- Window navigation (when NOT using vim-tmux-navigator — it handles these too)
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>', { silent = true })
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>', { silent = true })
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>', { silent = true })
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>', { silent = true })

-- <Space>r: quick compile+run for C++ (competitive-programming habit)
vim.keymap.set('n', '<leader>r',
    ':w<CR>:term g++ -std=c++17 -O2 % -o %< -Wall && chmod +x %< && ./%<<CR>',
    { silent = true })

-- Clear search highlight
vim.keymap.set('n', '<esc><esc>', ':noh<CR>', { silent = true })

-- System clipboard
vim.opt.clipboard = 'unnamedplus'
