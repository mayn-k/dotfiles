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

-- <Space>r: smart compile+run
--   C   + Makefile   → make          (embedded or multi-file project)
--   C   + CMake      → cmake --build build
--   C   (no build)   → gcc all *.c in cwd, -I. covers local headers, then run
--   C++ (no build)   → g++ single-file (competitive-programming habit)
vim.keymap.set('n', '<leader>r', function()
    vim.cmd('w')
    local ft  = vim.bo.filetype
    local cwd = vim.fn.getcwd()

    if ft == 'cpp' then
        if vim.fn.filereadable(cwd .. '/Makefile') == 1 then
            vim.cmd('term make')
        elseif vim.fn.filereadable(cwd .. '/CMakeLists.txt') == 1 then
            vim.cmd('term cmake --build build')
        else
            vim.cmd('term g++ -std=c++17 -O2 % -o %< -Wall && ./%<')
        end
    elseif ft == 'c' then
        if vim.fn.filereadable(cwd .. '/Makefile') == 1 then
            vim.cmd('term make')
        elseif vim.fn.filereadable(cwd .. '/CMakeLists.txt') == 1 then
            vim.cmd('term cmake --build build')
        else
            -- Compile every .c in cwd; -I. resolves local headers; output named after current file
            vim.cmd('term gcc -std=c11 -Wall -Wextra $(find . -maxdepth 1 -name "*.c") -I. -o %< && ./%<')
        end
    end
end, { silent = true, desc = 'Compile and run C/C++' })

-- Clear search highlight
vim.keymap.set('n', '<esc><esc>', ':noh<CR>', { silent = true })

-- System clipboard
vim.opt.clipboard = 'unnamedplus'
