# Powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source ~/.powerlevel10k/powerlevel10k.zsh-theme
test -f ~/.p10k.zsh && source ~/.p10k.zsh

# Add ~/.bin to PATH if it exists.
if test -d "$HOME/.bin"; then
  export PATH="$HOME/.bin:$PATH"
fi

# Add neovim to PATH if it exists in .bin.
if test -d "$HOME/.bin/nvim/bin"; then
  export PATH="$HOME/.bin/nvim/bin:$PATH"
fi

# Extended tab completion with colours and menu selection.
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select

# Tab completion prompts.
zstyle ':completion:*' list-prompt '%SList: %M (%p)%s'
zstyle ':completion:*' select-prompt '%SMenu: %M (%p)%s'
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Make case-insensitive.

# Show hidden files in tab completion.
_comp_options+=(globdots)

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
setopt inc_append_history  # Append commands as soon as they are executed, rather than at the end of the session.
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

# Keyboard shortcuts.
bindkey "^[^[[D" backward-word  # Navigating by word on remote Linux machine using option+left/right.
bindkey "^[^[[C" forward-word
bindkey "^[[1;3D" backward-word  # Navigating by word on macOS using option+left/right.
bindkey "^[[1;3C" forward-word
bindkey "^[[A" history-search-backward  # Search history with up and down keys using the typed prefix.
bindkey "^[[B" history-search-forward
bindkey "^O" backward-kill-line  # Delete from cursor to beginning of line.
bindkey "^P" kill-line  # Delete from cursor to end of line.

# Set default editor to neovim.
export EDITOR=nvim

# less options.
export LESSHISTFILE=/dev/null  # Prevent `less` from logging history.
export LESS='--mouse'  # Enable mouse scrolling in `less`.

# fzf integration.
export FZF_DEFAULT_OPTS="
  --height 75%
  --preview 'echo {}'
  --preview-window down:3:wrap
  --border"
export FZF_TMUX_OPTS="-p80%,80%"

# Aliases.
alias ls='eza -a --icons --group-directories-first'  # Replace ls with eza.
alias grep='grep --color=auto -in'  # Set grep options. Colour, case-insensitive, show line numbers.
alias vi='nvim'  # Use neovim as default editor.
alias v='nvim'
alias python=python3  # Set default python version.
alias pip=pip3  # Set default pip version.
alias print_colors='for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\''\n'\''}; done'

# Load API keys and other private configuration if available.
test -f ~/.api_keys.zsh && source ~/.api_keys.zsh
test -f ~/.private.zsh && source ~/.private.zsh

# Load OS-specific configuration.
if test "$(uname)" = "Darwin"; then
  source ~/.config/zsh/macos.zsh
else
  source ~/.config/zsh/linux.zsh
fi

# Fish-style autocomplete.
source ~/.config/zsh/zsh-autosuggestions.zsh

# Enable syntax highlighting.
# Note: This must be at the end of .zshrc
source ~/.config/zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Remove underlines from path highlighting.
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
# Make comments a readable color.
ZSH_HIGHLIGHT_STYLES[comment]='fg=245'
