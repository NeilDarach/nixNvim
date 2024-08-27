local colorschemer = nixCats("colorscheme")
if not require("nixCatsUtils").isNixCats then
	colorschemer = "onedark"
end

if colorschemer == "onedark" then
	require("onedark").setup({
		style = "darker",
		colors = {
			comment_grey = "#acb2bc",
		},
		highlights = {
			["@comment"] = { fg = "comment_grey" },
		},
	})
	require("onedark").load()
end
if colorschemer ~= "" then
	vim.cmd.colorscheme(colorschemer)
end
