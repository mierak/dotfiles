require("formatter").setup {
    logging = false,
    filetype = {
        lua = {
            require("formatter.filetypes.lua").stylua,
        },
        ts = {
            require("formatter.filetypes.typescript").prettier,
        },
        rs = {
            require("formatter.filetypes.rust").rustfmt,
        }
    }
}

