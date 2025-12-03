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
# the glob itself as an argument. This makes it easier to use commands shared by people running
# bash.
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
setopt share_history  # Share history between all sessions.
setopt inc_append_history # Append commands immediately. Implied by share_history. 
setopt extended_history  # Save command timestamp and duration.
setopt hist_expire_dups_first  # Delete oldest dupes first.
setopt hist_ignore_dups  # Do not write dupes to history.
setopt hist_ignore_space  # If first char is a space, command is not written to history.
setopt hist_find_no_dups  # Don't display dupes while searching through history.
setopt hist_reduce_blanks  # Remove extra blanks from commands added to history.
setopt hist_verify  # Don't execute when pressing enter for commands like `!!`, just expand.
setopt extended_glob  # Extended globbing. Required for using cached completions below.

# Other terminal options.
setopt nobeep  # No beeping on error.
setopt autopushd  # Enable auto directory stack.
setopt pushd_ignore_dups  # Don't add duplicate dirs to directory stack.
setopt interactive_comments  # Allow inline comments in interactive shells.

# GhosTTY terminfo is not widely available. For now, use `xterm-256color`.
if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
  export TERM=xterm-256color
fi

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

# Enable zoxide if it is available and Claude Code is not running.
if type zoxide &>/dev/null && [[ -z "$CLAUDECODE" ]]; then
  eval "$(zoxide init zsh --cmd cd)"
fi

# Function for changing the current directory with yazi.
yazicd() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# Watch for file changes then compile and run the program.
entrcc() {
  ls "$1" | entr -s "g++ -std=c++20 -o \"${1%.*}\" \"$1\" && \
    echo \"*** START [$(date +'%Y-%m-%d %H:%M:%S')] ***\" && \
    \"./${1%.*}\" && \
    echo \"*** END [$(date +'%Y-%m-%d %H:%M:%S')] ***\""
}
entrc() {
  ls "$1" | entr -s "gcc -std=c11 -o \"${1%.*}\" \"$1\" && \
    echo \"*** START [$(date +'%Y-%m-%d %H:%M:%S')] ***\" && \
    \"./${1%.*}\" && \
    echo \"*** END [$(date +'%Y-%m-%d %H:%M:%S')] ***\""
}
entrpy() {
  local python_bin=$(which python3)
  ls "$1" | entr -s "echo \"*** START [$(date +'%Y-%m-%d %H:%M:%S')] ***\" && \
    $python_bin \"$1\" && \
    echo \"*** END [$(date +'%Y-%m-%d %H:%M:%S')] ***\""
}

# Replace some substring in command output with ellipses. Pipe to this to make output more readable
# when it contains long paths or other strings that are repeated many times.
ellipses() {
  local pattern="$1"
  if [[ -z "$pattern" ]]; then
    echo "Usage: ellipses <pattern>" >&2
    return 1
  fi
  pattern=$(echo "$pattern" | sed 's/[\/&]/\\&/g') # Escape `/` and `&` for sed
  sed -E "s/$pattern/…/g"
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
abbr --force -q v='vi'
abbr --force -q l='yazicd'
abbr --force -q cpy='tmux capture-pane -pS -10000% | copy_to_clipboard'
abbr --force -q a2=' aria2c "%"'
abbr --force -q cdi='cd $HOME/Library/Mobile Documents/com~apple~CloudDocs'
abbr --force -q cdo='cd $HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Notes'

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
autoload -Uz compinit
# Cache completion data for 24 hours to speed up shell startup.
if [[ -f ~/.zcompdump && -z ~/.zcompdump(#qN.mh+24) ]]; then
  compinit -C
else
  compinit
fi

# Enable syntax highlighting.
# Note: This must be at the end of .zshrc
source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Remove underlines from path highlighting.
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
# Make comments a readable color.
ZSH_HIGHLIGHT_STYLES[comment]='fg=245'
