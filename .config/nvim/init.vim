set number relativenumber


" Restart sxhkd when it changes
autocmd BufWritePost ~/.config/sxhkd/sxhkdrc !killall sxhkd && sxhkd &
