if nixCats("typst") and (os.execute("command -v typst") == 0) then
    require("lze").load({
        "typst-preview.nvim",
        enabled = nixCats("typst"),
    })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "typst",
        callback = function()
            vim.keymap.set("n", "<leader>p", "<CMD>TypstPreviewToggle<CR>")
        end,
    })
end
