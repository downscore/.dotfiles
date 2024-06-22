# Set PATH, MANPATH, etc., for Homebrew.
if test "$(uname)" = "Darwin"; then
  # Run the Homebrew shell environment setup
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
