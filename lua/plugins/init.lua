require("lze").register_handlers(require('nixCatsUtils.lzUtils').for_cat)

-- NOTE: Register another one from lzextras. This one makes it so that
-- you can set up lsps within lze specs,
-- and trigger lspconfig setup hooks only on the correct filetypes
require('lze').register_handlers(require('lzextras').lsp)
-- demonstrated in ./LSPs/init.lua

require("plugins.colorscheme")
require("plugins.lsps")
require("plugins.treesitter")
require("plugins.fmt")
require("plugins.indent_line")
require("plugins.autocompletion")
require("plugins.gitsigns")
require("plugins.nvim-tree")
require("plugins.rust")
require("plugins.md-preview")
require("plugins.typst")
