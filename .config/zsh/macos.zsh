# Add Homebrew autocompletions if Homebrew is present.
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Load autocompletions.
autoload -Uz compinit && compinit

# Check if fzf is installed.
if type fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi

# OS-specific fzf setup.
export FZF_DEFAULT_OPTS="
  ${FZF_DEFAULT_OPTS}
  --bind 'ctrl-y:execute-silent(echo {} | pbcopy)+abort'
  --color header:italic
  --header 'Ctrl-Y: Copy'"

# Use bat for man pages if it is available.
if type bat &>/dev/null; then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi
