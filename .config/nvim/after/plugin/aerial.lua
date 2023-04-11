local icons = require("mrk.completion_icons")

require('aerial').setup({
    backends = { "lsp", "treesitter" },
    show_guides = true,
    -- optionally use on_attach to set keymaps when aerial has attached to a buffer
    icons = icons,
    filter_kind = {
        "Class",
        "Constructor",
        "Constant",
        "Enum",
        "Field",
        "Function",
        "Interface",
        "Method",
        "Property",
        "Package",
        "Module",
    },
    on_attach = function(bufnr)
        -- Jump forwards/backwards with '{' and '}'
        vim.keymap.set('n', '{', '<cmd>AerialPrev<CR>', {buffer = bufnr})
        vim.keymap.set('n', '}', '<cmd>AerialNext<CR>', {buffer = bufnr})
    end
})
