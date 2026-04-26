-- ~/.config/nvim/init.lua
-- Managed by dotfiles. Edit the repo version, then: stow -R nvim

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Load personal options first (sets mapleader before any plugin)
require("vim-options")

-- Load plugins from ~/.config/nvim/lua/plugins/*.lua
require("lazy").setup("plugins")
require("embed").setup()

-- Activate embed workflow commands and <leader>m* keymaps
-- (safe to call even if the embed.lua module is missing)

-- Format C/C++ on save (your existing behavior).
-- Uses clangd's LSP formatting if available, else falls back to clang-format binary.
vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = { "*.c", "*.cpp", "*.h" },
    callback = function()
        -- Prefer LSP formatter (respects .clang-format and is aware of the file)
        local clients = vim.lsp.get_clients({ bufnr = 0, name = "clangd" })
        if #clients > 0 then
            vim.lsp.buf.format({ async = false })
        else
            -- Fallback: pipe through clang-format binary
            if vim.fn.executable("clang-format") == 1 then
                vim.cmd("silent! %!clang-format")
            end
        end
    end,
})
