autoload -U colors && colors
PROMPT="%{$fg[blue]%}%{$bg[gray]%}  %{$fg[white]%}%B%n %b%{$fg[gray]%}%{$bg[white]%}%{$fg[gray]%}%{$bg[white]%}%B %~ %b%{$reset_color%}%{$fg[white]%}%{$reset_color%} "

# Lines configured by zsh-newuser-install
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/histfile"
HISTSIZE=1000000
SAVEHIST=1000000
setopt autocd extendedglob nomatch complete_aliases
unsetopt beep


##################################    
#                                #    
#         Autocomplete           #    
#                                #    
################################## 
fpath+="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
autoload -U compinit bashcompinit
zstyle ':completion:*' menu select
# Autocomplete commands prefixedd by "sudo" with elevated privileges
zstyle ':completion::complete:*' gain-privileges 1
zmodload zsh/complist
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
# Enable support for bash-style autocomplete scripts
bashcompinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
# Include hidden files
_comp_options+=(globdots)

bindkey -v
export KEYTIMEOUT=1
# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char


##################################    
#                                #    
# Source aliases and other stuff #    
#                                #    
##################################
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/.aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/.aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zshnameddir" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zshnameddir"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/cdalias" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/cdalias"

##################################
#                                #
#         Vi modes caret         #
#                                #
##################################

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Edit terminal command in vim with ctrl-e
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

##################################
#                                #
#             Misc               #
#                                #
##################################

eval "$(zoxide init zsh)"

lf () {
    tmp="$(mktemp)"
    command lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp" >/dev/null 2>&1
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}
bindkey -s '^f' '^ulf\n'
#bindkey -s '^m' '^utmux attach -t $(tmux list-sessions | fzf | cut -f1 -d ":")\n'

# Bind sxiv thumbnail mode in cwd
bindkey -s '^t' 'nsxiv -t .^M'
bindkey '^R' history-incremental-search-backward
##################################
#                                #
#            Plugins             #
#                                #
##################################
# Syntax highlight plugin
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
