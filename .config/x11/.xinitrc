#!/bin/sh

if [ -f ~/desktop.* ]; then
	feh --no-fehbg --bg-fill ~/desktop.*
fi
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/x11/.Xresources" ] && xrdb -merge "${XDG_CONFIG_HOME:-$HOME/.config}/x11/.Xresources" 
picom -b
xinput --set-prop 9 'libinput Accel Profile Enabled' 0, 1
redshift &
sxhkd &
exec awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr
