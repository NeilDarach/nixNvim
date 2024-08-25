return {
	{ -- Add indentation guides even on blank lines
		-- :help ibl
		"lukas-reineke/indent-blankline.nvim",
		enabled = require("nixCatsUtils").enableForCategory("indent_line"),
		main = "ibl",
		opts = {},
	},
}
