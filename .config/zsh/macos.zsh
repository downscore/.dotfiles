# ctrl-v is a no-op since we can directly access the system clipboard in local sessions.
bindkey '^v' undefined-key

# Add Homebrew autocompletions if Homebrew is present.
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# Check if fzf is installed.
if type fzf &>/dev/null; then
  eval "$(fzf --zsh)"
fi

# OS-specific aliases and abbreviations.
abbr --force -q ldd='otool -L'
