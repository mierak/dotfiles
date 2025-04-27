#!/bin/sh

marks="d ~/Downloads
r ~/Repos
p ~/Projects
c ~/.config
b ~/.local/bin
s ~/.local/share
m /mnt
a /run/user/1000/gvfs
R /
t /tmp"

if command -v crossmarks >/dev/null 2>&1; then
    echo "$marks" | crossmarks \
        --lf "${XDG_CONFIG_HOME:-HOME/.config}"/lf/bookmarks \
        --zsh "${XDG_CONFIG_HOME:-HOME/.config}"/zsh/zshnameddir \
        --cd-alias "${XDG_CONFIG_HOME:-HOME/.config}"/shell/cdalias
fi
