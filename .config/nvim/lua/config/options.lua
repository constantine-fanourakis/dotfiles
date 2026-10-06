-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_picker = "snacks"
vim.g.snacks_animate = false
vim.g.snacks_indent = true

vim.g.autoformat = false

vim.o.autoread = true

-- Set to "basedpyright" to use basedpyright instead of pyright.
vim.g.lazyvim_python_lsp = "basedpyright"

-- Enable line wrapping
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.linebreak = true
vim.opt.showbreak = "↪ "

-- 80 char column
vim.opt.colorcolumn = "80"

-- Set window title
vim.opt.title = true

-- No mouse clicky
-- vim.opt.mouse = ""
-- Disable left mouse click
vim.keymap.set("", "<LeftMouse>", "<nop>", { noremap = true })
vim.keymap.set("i", "<LeftMouse>", "<nop>", { noremap = true })

-- No mouse scrolly (doesn't work well in ghostty)
-- vim.opt.mousescroll = "ver:0,hor:0"
-- vim.keymap.set("", "<up>", "<nop>", { noremap = true })
-- vim.keymap.set("", "<down>", "<nop>", { noremap = true })
-- vim.keymap.set("i", "<up>", "<nop>", { noremap = true })
-- vim.keymap.set("i", "<down>", "<nop>", { noremap = true })

-- Spaces!!!
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.softtabstop = 4
