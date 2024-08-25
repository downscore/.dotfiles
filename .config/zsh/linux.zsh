# Use batcat for man pages.
export MANPAGER="sh -c 'col -bx | batcat -l man -p'"

# Use batcat (not "bat") as the default pager on linux.
export PAGER="batcat --paging=always"

# OS-specific fzf setup.
export FZF_DEFAULT_OPTS="
  ${FZF_DEFAULT_OPTS}
  --bind 'ctrl-y:execute-silent(echo -n {2..} | xclip -selection clipboard)+abort'
  --color header:italic
  --header 'Ctrl-Y: Copy'"
export FZF_CTRL_T_OPTS="--bind 'ctrl-y:execute-silent(echo -n {} | xclip -selection clipboard)+abort'"
