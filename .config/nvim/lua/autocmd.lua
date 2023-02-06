local group = vim.api.nvim_create_augroup("Restart", { clear = true })

vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = vim.env.HOME .. "/.config/sxhkd/sxhkdrc",
    group = group,
    callback = function ()
        io.popen("killall sxhkd && sxhkd & disown")
    end
})
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = vim.env.HOME .. "/.config/dunst/dunstrc",
    group = group,
    callback = function ()
        io.popen("killall dunst && dunst & disown")
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    group = group,
    callback = function ()
        vim.opt_local.formatoptions = "jql"
    end
})

