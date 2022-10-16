#!/bin/sh

bg="/home/mrk/.local/share/wallpaper/current"
if [ -f "$bg" ]; then
	setbg
fi
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/x11/.Xresources" ] && xrdb -merge "${XDG_CONFIG_HOME:-$HOME/.config}/x11/.Xresources" 
picom -b
xinput --set-prop 9 'libinput Accel Profile Enabled' 0, 1
redshift &
sxhkd &
dunst &
#dwmblocks &
#exec ~/.config/x11/dwmauto
exec xmonad
