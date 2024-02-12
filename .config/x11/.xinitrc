#!/bin/sh

bg="/home/mrk/.local/share/wallpaper/current"
if [ -f "$bg" ]; then
	setbg
fi
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/x11/.Xresources" ] && xrdb "${XDG_CONFIG_HOME:-$HOME/.config}/x11/.Xresources" 
mpd &
picom -b
xinput --set-prop 9 'libinput Accel Profile Enabled' 0, 1
redshift &
#sxhkd &
#dunst &
lxsession &
unclutter -b
xrandr --output DisplayPort-0 --off --output DisplayPort-1 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI-A-0 --mode 1920x1080 --pos 3840x300 --rotate normal --output HDMI-A-1 --mode 1920x1080 --pos 0x300 --rotate normal
exec awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr
