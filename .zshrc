# Powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source ~/.powerlevel10k/powerlevel10k.zsh-theme
test -f ~/.p10k.zsh && source ~/.p10k.zsh

# Fish-style autocomplete and abbreviations.
source ~/.config/zsh/zsh-autosuggestions.zsh
source ~/.config/zsh/zsh-abbr/zsh-abbr.zsh
# Allow placing the cursor inside an abbreviation.
ABBR_SET_EXPANSION_CURSOR=1

# Tab completion options.
zstyle ':completion:*' menu select
zstyle ':completion:*' list-prompt '%SList: %M (%p)%s'
zstyle ':completion:*' select-prompt '%SMenu: %M (%p)%s'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Make case-insensitive.
_comp_options+=(globdots)  # Show hidden files in tab completion.

# Use bash-style globbing -- don't raise an error when * doesn't match anything, and just pass in
# the glob itself as an argument. This makes it easier to use share commands with people running
# bash terminals.
setopt nonomatch

# Colors for use in prompts, ls, tab completion, etc.
autoload -U colors && colors
export CLICOLOR=1
export LSCOLORS=Exfxcxdxbxegedabagacad
export LS_COLORS='di=1;34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Bulk renaming tool.
autoload -U zmv

# History options.
HISTFILE=~/.zsh_history
HISTSIZE=200000
SAVEHIST=200000
# Only include `cd` commands containing a slash in history.
HISTORY_IGNORE='(ls|cd [^/]*|pwd|exit)'
setopt append_history  # Append commands to the history file, rather than overwriting it.
# Append commands as soon as they are executed, rather than at the end of the session.
setopt inc_append_history
setopt share_history  # Share history between all sessions.
setopt extended_history  # Save command timestamp and duration.
setopt hist_expire_dups_first  # Delete oldest dupes first.
setopt hist_ignore_dups  # Do not write duped to history.
setopt hist_ignore_space  # If first char is a space, command is not written to history.
setopt hist_find_no_dups  # Don't display dupes while searching through history.
setopt hist_reduce_blanks  # Remove extra blanks from commands added to history.
setopt hist_verify  # Don't execute when pressing enter, just expand.

# Other terminal options.
setopt nobeep  # No beeping on error.
setopt autopushd  # Enable auto directory stack.
setopt interactive_comments  # Allow inline comments in interactive shells.

# Reduce delay after receiving an escape key code (^[). Note that some keys (such as arrow keys)
# send an escape key code followed by another code, so the terminal waits for a bit to
# disambiguate. Reducing this from the default 400ms (but not to zero) can help with responsiveness.
KEYTIMEOUT=10  # In 10ms units.

# Keyboard shortcuts.
# Navigating by word on remote Linux machine using option+left/right.
bindkey "^[^[[D" backward-word
bindkey "^[^[[C" forward-word
bindkey "^[[1;3D" backward-word  # Navigating by word on macOS using option+left/right.
bindkey "^[[1;3C" forward-word
# Search history with up and down keys using the typed prefix.
bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward
bindkey "^O" backward-kill-line  # Delete from cursor to beginning of line.
bindkey "^P" kill-line  # Delete from cursor to end of line.

# Zle widget to copy the current zsh buffer and cursor position to the clipboard.
# Used for textflow support in the terminal.
zle_copy_buffer_and_cursor_location() {
  copy_to_clipboard "${CURSOR},${BUFFER}"
}
zle -N zle_copy_buffer_and_cursor_location
bindkey '^Xy' zle_copy_buffer_and_cursor_location

# Zle widget to copy the current zsh buffer to the clipboard.
zle_copy_buffer() {
  copy_to_clipboard "${BUFFER}"
}
zle -N zle_copy_buffer
bindkey '^y' zle_copy_buffer

# Zle widget to copy the tmux buffer to the clipboard.
zle_tmux_buffer_to_clipboard() {
  tmux save-buffer - | copy_to_clipboard
}
zle -N zle_tmux_buffer_to_clipboard

# Enable zoxide if it is available.
if type zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  # Replace `cd` with zoxide.
  alias cd='z'
fi

# Function for changing the current directory with lf.
lfcd () {
  # `command` is needed in case `lfcd` is aliased to `lf`
  cd "$(command lf -print-last-dir "$@")"
}

# Command aliases and abbreviations.
if type eza &>/dev/null; then
  alias ls='eza -a --icons --group-directories-first'  # Replace ls with eza.
fi
if type nvim &>/dev/null; then
  alias vi='nvim'  # Use neovim as default editor.
fi
alias python=python3  # Set default python version.
alias pip=pip3  # Set default pip version.
alias print_colors='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\''\n'\''}; done'
alias mansyscall='manfzf 2'
alias manlib='manfzf 3'
abbr --force -q ll='ls -al'
abbr --force -q v='vi'
abbr --force -q l='lfcd'
abbr --force -q lg='lazygit'
abbr --force -q cpy='tmux capture-pane -pS -10000% | copy_to_clipboard'  # Cursor after num lines.

# Load API keys and other private configuration if available.
test -f ~/.api_keys.zsh && source ~/.api_keys.zsh
test -f ~/.private.zsh && source ~/.private.zsh

# Load OS-specific configuration.
if test "$(uname)" = "Darwin"; then
  source ~/.config/zsh/macos.zsh
else
  source ~/.config/zsh/linux.zsh
fi

# Load completion scripts after os-specific completion data has been loaded.
autoload -Uz compinit && compinit

# Enable syntax highlighting.
# Note: This must be at the end of .zshrc
source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Remove underlines from path highlighting.
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
# Make comments a readable color.
ZSH_HIGHLIGHT_STYLES[comment]='fg=245'
