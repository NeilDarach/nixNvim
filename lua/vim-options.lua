vim.cmd("set noexpandtab")
vim.cmd("set tabstop=8")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Navigate vim panes better
vim.keymap.set('n', '<c-k>', ':wincmd k<CR>')
vim.keymap.set('n', '<c-j>', ':wincmd j<CR>')
vim.keymap.set('n', '<c-h>', ':wincmd h<CR>')
vim.keymap.set('n', '<c-l>', ':wincmd l<CR>')

-- Search elements say higlighted until cancelled
vim.o.hlsearch = true
vim.keymap.set('n', '<leader>h', ':nohlsearch<CR>')
vim.keymap.set('n', '<ESC>', ':nohlsearch<CR>')

-- Line numbers
vim.wo.number = true
vim.wo.relativenumber = true

if vim.g.neovide then
  vim.keymap.set('v', '<D-c>', '"+y') -- Copy
  vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
  vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
  vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
  vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- Paste insert mode
end

-- Allow clipboard copy paste in neovim
vim.api.nvim_set_keymap('','<D-v>', '+p<CR>', {  noremap = true, silent = true })
vim.api.nvim_set_keymap('!','<D-v>', '<C-R>+', {  noremap = true, silent = true })
vim.api.nvim_set_keymap('t','<D-v>', '<C-R>+', {  noremap = true, silent = true })
vim.api.nvim_set_keymap('v','<D-v>', '<C-R>+', {  noremap = true, silent = true })

-- Easy exit from leader state
vim.keymap.set({'n','v'}, '<Space>', '<Nop>', { silent = true })
vim.keymap.set({'n'}, 'q', '<Nop>', { silent = true })

-- Preserve indent for wrapped lines
vim.o.breakindent = false
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.termguicolors = true
vim.api.nvim_set_option("clipboard","unnamedplus")


vim.highlight.priorities.semantic_tokens = 95
