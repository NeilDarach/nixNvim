require("lze").load({
	"stevearc/conform.nvim",
	keys = "<leader>f",
	after = function(plugin)
		local conform = require("conform")
		conform.setup({
			formatters_by_ft = {
				lua = { "stylua" },
				nix = { "nixfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				cmake = { "cmake_format" },
			},
		})
		vim.keymap.set({ "n", "v" }, "<leader>f", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "[F]ormat file" })
	end,
})
