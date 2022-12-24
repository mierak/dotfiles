local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
--[[ local opts = { noremap=true, silent=true } ]]--


local on_attach = function(client, bufnr)
  local bufopts = { buffer=bufnr }
  vim.keymap.set('n', '<leader>d', vim.diagnostic.goto_next, bufopts)
  vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev, bufopts)
  vim.keymap.set('n', '<leader>dl', "<cmd>Telescope diagnostics<cr>", bufopts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', 'gr', "<cmd>Telescope lsp_references<cr>", bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader><F2>', vim.lsp.buf.rename, bufopts)
end

require'lspconfig'.bashls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
require'lspconfig'.tsserver.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
require'lspconfig'.ccls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
require'lspconfig'.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}
require'lspconfig'.sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = vim.loop.cwd,
  settings = {
    Lua = {
      workspace = {
        library = {
          ['/usr/share/nvim/runtime/lua'] = true,
          ['/usr/share/nvim/runtime/lua/lsp'] = true,
          ['/usr/share/awesome/lib'] = true
        }
      },
      diagnostics = {
        enable = true,
        globals = {
          -- VIM
          "vim", "use", -- Packer use keyword
          -- AwesomeWM
          "awesome", "client", "root", "screen"
        }
      }
    }
  },
}

require("autocomp")

