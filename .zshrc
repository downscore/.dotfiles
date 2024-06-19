# Powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
source ~/.powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Add Homebrew autocompletions if Homebrew is present.
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
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

# Colors for use in prompts, etc.
autoload -U colors && colors

# Colors for ls and tab completion.
export CLICOLOR=1
# export LSCOLORS=Gxfxcxdxbxegedabagacad
export LSCOLORS=Exfxcxdxbxegedabagacad
export LS_COLORS='di=1;34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Bulk renaming tool.
autoload -U zmv

# Extended filename globbing. Allows negation, approximate matching, and qualifiers.
# Note: May interfere with some comands. e.g. git commands that use carets.
# setopt extended_glob

# Suggest spelling corrections for mistyped commands.
# Note: May have false positives with newly-created binaries.
# setopt correct
# export SPROMPT="Correct $fg[red]%R$reset_color to $fg[green]%r?$reset_color (y)es, (n)o, (a)bort, (e)dit: "

# Share history between multiple terminals.
setopt append_history
setopt inc_append_history
setopt share_history

# Other history options.
HISTSIZE=200000
SAVEHIST=200000
# Only include `cd` commands containing a slash in history.
HISTORY_IGNORE='(ls|cd [^/]*|pwd|exit)'
setopt extended_history # Save command timestamp and duration.
setopt hist_expire_dups_first # Delete oldest dupes first.
setopt hist_ignore_dups # Do not write duped to history.
setopt hist_ignore_space # If first char is a space, command is not written to history.
setopt hist_find_no_dups # Don't display dupes while searching through history.
setopt hist_reduce_blanks # Remove extra blanks from commands added to history.
setopt hist_verify # Don't execute when pressing enter, just expand.

# Prevent `less` from logging history.
export LESSHISTFILE=/dev/null

# No beeping on error.
setopt nobeep

# Enable auto dir stack.
setopt autopushd

# Allow inline comments in interactive shells.
setopt interactive_comments

# fzf integration.
eval "$(fzf --zsh)"
export FZF_DEFAULT_OPTS="
  --height 75%
  --preview 'echo {}'
  --preview-window down:3:wrap
  --layout=reverse --border"
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Ctrl-Y to copy command to clipboard'"

# Replace ls with exa.
alias ls='exa -a --icons'

# Set grep options. Colour, case-insensitive, show line numbers.
alias grep='grep --color=auto -in'

# Set default python version.
alias python=python3
alias pip=pip3

# API keys.
[[ ! -f ~/.api_keys.zsh ]] || source ~/.api_keys.zsh

# iTerm2 shell integration.
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Fish-style autocomplete.
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Enable syntax highlighting.
# Note: This must be at the end of .zshrc
source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
ZSH_HIGHLIGHT_STYLES[comment]=fg-245
