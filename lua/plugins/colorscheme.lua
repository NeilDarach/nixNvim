local colorschemer = nixCats("colorscheme")
if not require("nixCatsUtils").isNixCats then
	colorschemer = "onedark"
end

-- comment
if colorschemer == "onedark" then
	require("onedark").setup({
		style = "darker",
		highlights = {
			["Comment"] = { fg = "gray" },
		},
	})
	require("onedark").load()
end
if colorschemer ~= "" then
	vim.cmd.colorscheme(colorschemer)
    vim.cmd([[hi Normal guibg=NONE ctermbg=NONE]])
    vim.cmd([[hi EndOfBuffer guibg=NONE ctermbg=NONE]])
    vim.cmd([[hi StatusLine guibg=NONE ctermbg=NONE]])
end
