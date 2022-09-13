call plug#begin('~/.local/share/nvim/plugged')
Plug 'ap/vim-css-color'
Plug 'preservim/nerdtree'
Plug 'jreybert/vimagit'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'frazrepo/vim-rainbow'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/nvim-cmp'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'catppuccin/nvim', {'as': 'catppuccin'}
call plug#end()

lua require("catppuccin_theme")
lua require("lsp")

set number relativenumber
set title

let g:airline_powerline_fonts = 1
let g:airline_theme='bubblegum'
" Rainbow brackets
let g:rainbow_active = 1

" Enable autocompletion
set wildmode=longest,list,full

" Disable auto comment
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Restart sxhkd when it changes
autocmd BufWritePost ~/.config/sxhkd/sxhkdrc !killall sxhkd && sxhkd &

" Reload Xresources when it changes
autocmd BufWritePost ~/.config/x11/.Xresources !xrdb ~/.config/x11/.Xresources

" Reload dunst when it changes
autocmd BufWritePost ~/.config/dunst/dunstrc !killall dunst && dunst &
