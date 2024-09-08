# Set PATH, MANPATH, etc., for Homebrew.
if test "$(uname)" = "Darwin"; then
  if test -f "/opt/homebrew/bin/brew"; then
    # Run the Homebrew shell environment setup
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# Get appropriate clipboard command for the system.
if type pbcopy &>/dev/null; then
  export CLIPBOARD_WRITE='pbcopy'
else
  # Uncomment to use xclip if X11 forwarding works properly.
  # export CLIPBOARD_WRITE='xclip -selection clipboard'
  export CLIPBOARD_WRITE='$HOME/.dotfiles/scripts/copy_to_tmux_buffer'
fi

# fzf integration.
export FZF_DEFAULT_OPTS="
  --height 75%
  --layout=reverse
  --preview 'echo {}'
  --preview-window down:3:wrap
  --border
  --bind 'ctrl-y:execute-silent(echo -n {} | $CLIPBOARD_WRITE)+abort'
  --color header:italic
  --header 'Ctrl-Y: Copy'"
export FZF_CTRL_R_OPTS="--bind 'ctrl-y:execute-silent(echo -n {2..} | $CLIPBOARD_WRITE)+abort'"
export FZF_TMUX_OPTS="-p80%,80%"
