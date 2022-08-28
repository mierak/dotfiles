# Set up prompt, prints green checkmark when exit code is 0, red cross otherwise
PROMPT="%B%F{red}[%f%b%B%F{yellow}%n%f%b%B%F{green}@%f%b%B%F{blue}%m%f%b %F{magenta}%~%f%B%F{red}]%f%b%B$%b "


# Lines configured by zsh-newuser-install
HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/histfile"
HISTSIZE=1000000
SAVEHIST=1000000
setopt autocd extendedglob nomatch
unsetopt beep


##################################    
#                                #    
#         Autocomplete           #    
#                                #    
################################## 
autoload -U compinit 
zstyle ':completion:*' menu select
# Autocomplete commands prefixedd by "sudo" with elevated privileges
zstyle ':completion::complete:*' gain-privileges 1
zmodload zsh/complist
compinit
# Include hidden files
_comp_options+=(globdots)

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
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/.shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/.shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/.aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/.aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/.zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/.zshnameddirrc"


##################################
#                                #
#         Vi modes caret         #
#                                #
##################################
bindkey -v
export KEYTIMEOUT=1

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


##################################
#                                #
#             Misc               #
#                                #
##################################


##################################
#                                #
#            Plugins             #
#                                #
##################################
# Syntax highlight plugin
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null


