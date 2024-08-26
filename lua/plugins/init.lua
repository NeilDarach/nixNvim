--require('plugins.lazyinit')
local colorschemer = nixCats("colorscheme")
if not require("nixCatsUtils").isNixCats then
	colorschemer = "onedark"
end

if colorschemer == "onedark" then
	require("onedark").setup({
		style = "dark",
	})
	require("onedark").load()
end
if colorschemer ~= "" then
	vim.cmd.colorscheme(colorschemer)
end
