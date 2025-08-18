-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- normal mode: Alt+Enter
vim.keymap.set("n", "<M-CR>", vim.lsp.buf.code_action, { desc = "Code Action (Alt+Enter)" })

-- visual mode: Alt+Enter
vim.keymap.set("v", "<M-CR>", vim.lsp.buf.code_action, { desc = "Code Action (Alt+Enter)" })
