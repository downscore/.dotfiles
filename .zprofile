# Set up Homebrew environment (must be in .zprofile, not .zshenv, because
# macOS's /etc/zprofile runs path_helper which reorders PATH after .zshenv)
if [[ "$(uname)" == "Darwin" && -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
