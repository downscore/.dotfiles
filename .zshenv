# Set PATH, MANPATH, etc., for Homebrew.
if test "$(uname)" = "Darwin"; then
  if test -f "/opt/homebrew/bin/brew"; then
    # Run the Homebrew shell environment setup
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# Add ~/.bin to PATH if it exists.
if test -d "$HOME/.bin"; then
  export PATH="$HOME/.bin:$PATH"
fi

# Add neovim to PATH if it exists in .bin.
if test -d "$HOME/.bin/nvim/bin"; then
  export PATH="$HOME/.bin/nvim/bin:$PATH"
fi

# Add ~/.dotfiles/scripts to PATH if it exists.
if test -d "$HOME/.dotfiles/scripts"; then
  export PATH="$HOME/.dotfiles/scripts:$PATH"
fi

# Add custom C++ includes to the compiler's include path. Colon separated paths.
if test -d "$HOME/Documents/Code/IncludeCPP"; then
  # Check if CPLUS_INCLUDE_PATH is already set, if not, set it.
  if [[ -z "$CPLUS_INCLUDE_PATH" ]]; then
    export CPLUS_INCLUDE_PATH="$HOME/Documents/Code/IncludeCPP"
  else
    # Append to existing CPLUS_INCLUDE_PATH.
    export CPLUS_INCLUDE_PATH="$HOME/Documents/Code/IncludeCPP:$CPLUS_INCLUDE_PATH"
  fi
fi

# Set default editor to neovim if it is available.
if type nvim &>/dev/null; then
  export EDITOR=nvim
  export VISUAL=nvim
fi

# Pager options.
export LESSHISTFILE=/dev/null  # Prevent `less` from logging history.
# Less options:
# -R: Allow color and hyperlink escape sequences.
# -I: Ignore case in all-lowercase searches.
# -i: Smart case in searches containing uppercase characters.
# -jn: Show at least n lines above or below search matches.
# --incsearch: Incremental search.
# --mouse: Enable mouse scrolling.
# -J: Status column (disabled as it messes with bat). Shows lines with search matches in the gutter.
export LESS='-RIij10 --incsearch --mouse'
if type batcat &>/dev/null; then
  # Use `batcat` as the default pager. Try it first to prevent problems with "bat" on linux.
  export PAGER='batcat --paging=always'
  # Note: The -p option messes with --paging=always, but --style=plain does not.
  export MANPAGER="batcat -l man --paging=always --style=plain'"
elif type bat &>/dev/null; then
  export PAGER='bat --paging=always'  # Use `bat` as the default pager.
  # Note: The -p option messes with --paging=always, but --style=plain does not.
  export MANPAGER="sh -c 'col -bx | bat -l man --paging=always --style=plain'"
fi
export BAT_STYLE=changes,numbers,snip

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
