#!/bin/sh

if [ -f ~/desktop.* ]; then
	feh --no-fehbg --bg-fill "${XDG_DATA_HOME:-$HOME/.local/share}/wallpaper/reimu.jpg"
fi
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/x11/.Xresources" ] && xrdb -merge "${XDG_CONFIG_HOME:-$HOME/.config}/x11/.Xresources" 
picom -b
xinput --set-prop 9 'libinput Accel Profile Enabled' 0, 1
redshift &
sxhkd &
dunst &
exec awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr
