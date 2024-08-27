require("lze").load({
	"nvim-treesitter",
	event = "DeferredUIEnter",
	dep_of = { "treesj", "otter.nvm", "hlargs", "render-markdown", "neorg" },
	load = function(name) end,
	after = function(plugin)
		vim.defer_fn(function()
			require("nvim-treesitter.configs").setup({
				highlight = {
					enable = true,
				},
				indent = { enable = false },
				incremental_selection = {
					enable = true,
					keymaps = {},
				},
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {},
						goto_next_end = {},
						goto_previous_start = {},
						goto_previous_end = {},
					},
					swap = {
						enable = true,
						swap_next = {},
						swap_previous = {},
					},
				},
			})
		end, 0)
	end,
})
