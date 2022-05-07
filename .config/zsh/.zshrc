####                                                     ####
### Personal Z-Shell config based on Luke Smith's config. ###
####                                                     ####

## Enable colors and change prompt:
# Load colors
autoload -U colors && colors
# Set default prompt
PS1="%B%{$fg[red]%}[%{$fg[green]%}%n %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
# Automatically cd into typed directory.
setopt autocd		
# Disable ctrl-s to freeze terminal.
stty stop undef		
setopt interactive_comments

## History in cache directory:
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE="$HOME/.cache/zsh/history"

## Load aliases and shortcuts if existent.
[ -f "$HOME/.config/shell/shortcutrc" ] && source "$HOME/.config/shell/shortcutrc"
[ -f "$HOME/.config/shell/aliasrc" ] && source "$HOME/.config/shell/aliasrc"
[ -f "$HOME/.config/shell/zshnameddirrc" ] && source "$HOME/.config/shell/zshnameddirrc"

## Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select 
zmodload zsh/complist
compinit
# Include hidden files to autocompletion
_comp_options+=(globdots)

## vi mode
bindkey -v
export KEYTIMEOUT=1

## Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

## Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}

zle -N zle-keymap-select

zle-line-init() {
    # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    zle -K viins 
    echo -ne "\e[5 q"
}

zle -N zle-line-init
# Use beam shape cursor on startup.
echo -ne '\e[5 q' 

preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

## Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1' HUP INT QUIT TERM PWR EXIT
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' '^ulfcd\n'
bindkey -s '^a' '^ubc -lq\n'
bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'
bindkey '^[[P' delete-char

## Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete

## Source aliases
source $HOME/.config/shell/aliasrc

## Load Powerlevel10k shell prompt
source $HOME/.config/zsh/.p10k.zsh

## Load syntax highlighting; should be last.
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh 2>/dev/null

