set number relativenumber


" Restart sxhkd when it changes
autocmd BufWritePost ~/.config/sxhkd/sxhkdrc !killall sxhkd && sxhkd &

" Reload Xresources when it changes
autocmd BufWritePost ~/.config/x11/.Xresources !xrdb ~/.config/x11/.Xresources

" Reload dunst when it changes
autocmd BufWritePost ~/.config/dunst/dunstrc !killall dunst && sxhkd &
