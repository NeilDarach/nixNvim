require("lze").load({
    "rust.vim",
    enabled = nixCats("rust"),
    after = function(plugin)
        vim.g.rustfmt_autosave = 1
    end,
})

