require("formatter").setup {
    logging = true,
    filetype = {
        lua = {
            require("formatter.filetypes.lua").stylua,
        },
        typescript = {
            require("formatter.filetypes.typescript").prettier,
        },
        rs = {
            require("formatter.filetypes.rust").rustfmt,
        }
    }
}

