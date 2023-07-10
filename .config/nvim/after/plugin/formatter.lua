require("formatter").setup {
    logging = true,
    filetype = {
        lua = {
            require("formatter.filetypes.lua").stylua,
        },
        typescript = {
            require("formatter.filetypes.typescript").prettier,
        },
        rust = {
            require("formatter.filetypes.rust").rustfmt,
        },
        c = {
            require("formatter.filetypes.c").clangformat,
        }
    }
}

