local group = vim.api.nvim_create_augroup("GitGutter", { clear = true })
vim.api.nvim_create_autocmd("BufWinEnter", {
    pattern = "*",
    group = group,
    callback = function (args)
        if args.file:match(".config.*") or args.file:match(".local/bin.*") or args.file:match(".local/share.*") then
            vim.g.gitgutter_git_args = '--git-dir=' .. vim.env.HOME .. '/.dots/ --work-tree=' .. vim.env.HOME
        else
            vim.g.gitgutter_git_args = ''
        end
    end
})
