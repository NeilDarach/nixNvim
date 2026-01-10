require("lze").load({
	"conform.nvim",
    for_cat = "format",
	keys = { { "<leader>f","[f]ormat file" }, },
	after = function(plugin)
		local conform = require("conform")
		formatters_by_ft = { }
		if nixCats("bash") then formatters_by_ft["bash"] = { "shfmt" } end
		if nixCats("lua") then formatters_by_ft["lua"] = { "sytlua" } end
		if nixCats("nix") then formatters_by_ft["nix"] = { "nixfmt" } end
		if nixCats("c") then formatters_by_ft["c"] = { "clang_format" } end
		if nixCats("cpp") then formatters_by_ft["cpp"] = { "clang_format" } end
		if nixCats("cmake") then formatters_by_ft["cmake"] = { "cmake_format" } end
		conform.setup({ formatters_by_ft = formatters_by_ft })
		vim.keymap.set({ "n", "v" }, "<leader>f", function()
			conform.format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "[f]ormat file" })
	end,
})
