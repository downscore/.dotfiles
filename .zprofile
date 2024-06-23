# Set PATH, MANPATH, etc., for Homebrew.
if test "$(uname)" = "Darwin"; then
  if test -f "/opt/homebrew/bin/brew"; then
    # Run the Homebrew shell environment setup
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi
