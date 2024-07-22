# Add Homebrew autocompletions if Homebrew is present.
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

# OS-specific fzf setup.
eval "$(fzf --zsh)"
export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Ctrl-Y to copy command to clipboard'"

# Use bat for man pages.
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
