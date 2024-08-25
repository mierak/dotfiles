eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/theme.omp.json)"

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/.aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/.aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zshnameddir" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/zshnameddir"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/cdalias" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/cdalias"

HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/histfile"
HISTSIZE=1000000
SAVEHIST=1000000
setopt autocd extendedglob nomatch complete_aliases 
setopt hist_ignore_all_dups
setopt appendhistory
setopt sharehistory
setopt hist_ignore_dups
setopt hist_find_no_dups
unsetopt beep

# Autocomplete
fpath+="${XDG_DATA_HOME:-$HOME/.local/share}/zsh"
autoload -U compinit bashcompinit
zmodload zsh/complist
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
bashcompinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
_comp_options+=(globdots)
zinit cdreplay -q

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu no
zstyle ':completion::complete:*' gain-privileges 1
zstyle ':fzf-tab:complete:*' fzf-preview 'exit'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Use vim keys in tab complete menu:
bindkey -v
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Edit terminal command in vim with ctrl-e
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

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
bindkey '^R' history-incremental-search-backward

function yy() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		\cd -- "$cwd"
	fi
	rm -f -- "$tmp" > /dev/null
}

# Plugins
zinit ice wait lucid && zinit light zdharma-continuum/fast-syntax-highlighting
zinit ice wait lucid && zinit light Aloxaf/fzf-tab
zinit ice wait lucid && zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
source <(fzf --zsh)

eval "$(zoxide init zsh)"
