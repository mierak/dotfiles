--local nvim_tree_events = require('nvim-tree.events')
--local bufferline_api = require('bufferline.api')
--
--local function get_tree_size()
--  return require'nvim-tree.view'.View.width
--end
--
--nvim_tree_events.subscribe('TreeOpen', function()
--  bufferline_api.set_offset(get_tree_size())
--end)
--
--nvim_tree_events.subscribe('Resize', function()
--  bufferline_api.set_offset(get_tree_size())
--end)
--
--nvim_tree_events.subscribe('TreeClose', function()
--  bufferline_api.set_offset(0)
--end)
--

require("bufferline").setup {
    options = {
        mode = "tabs",
        numbers = "ordinal",
        diagnostics = "nvim_lsp",
        color_icons = true,
        separator_style = "padded_slant",
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                text_align = "center",
                separator = true
            }
        }
    },
}
