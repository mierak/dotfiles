require("nvim-treesitter.configs").setup {
    ensure_installed = { "lua", "typescript", "javascript", "json", "html", "bash", "yaml", "gitignore", "css" },
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    }
}

