#!/bin/zsh
# Script to create symlinks for dotfiles.
# Idempotent: Will not overwrite existing files or symlinks.
# This script will also report any existing symlinks to incorrect locations.

print_red() {
  printf "\e[41;30m%s\e[0m\n" "$1"
}
print_green() {
  printf "\e[32m%s\e[0m\n" "$1"
}

create_symlink() {
  local file=$1
  local target=$2

  echo -n "$file: "
  if [[ -L "$file" && "$(readlink -f "$file")" == "$target" ]]; then
    print_green "OK Symlink to correct path already exists"
    return 0
  fi
  if [[ -e "$file" && ! -L "$file" ]]; then
    print_red "ERROR Exists and is not a symlink"
    return 1
  fi
  if [[ -e "$file" ]]; then
    # We established above that if the file exists, it must be a symlink to the wrong path.
    print_red "ERROR Exists and is symlinked to a different path"
    return 1
  fi
  if ln -s "$target" "$file"; then
    print_green "OK Successfully created symlink"
  else
    print_red "ERROR Failed to create symlink"
  fi
}

local DF="$HOME/.dotfiles"
local DFCFG="$DF/.config"
local CFG="$HOME/.config"
local APP_SUPPORT="$HOME/Library/Application Support"

create_symlink "$HOME/.zshrc" "$DF/.zshrc"
create_symlink "$HOME/.zprofile" "$DF/.zprofile"
create_symlink "$HOME/.zshenv" "$DF/.zshenv"
create_symlink "$HOME/.p10k.zsh" "$DF/.p10k.zsh"
create_symlink "$CFG/alacritty" "$DFCFG/alacritty"
create_symlink "$CFG/bat" "$DFCFG/bat"
create_symlink "$CFG/ghostty" "$DFCFG/ghostty"
create_symlink "$CFG/lf" "$DFCFG/lf"
create_symlink "$CFG/nvim" "$DFCFG/nvim"
create_symlink "$CFG/tmux" "$DFCFG/tmux"
create_symlink "$CFG/zsh" "$DFCFG/zsh"
create_symlink "$APP_SUPPORT/lazygit/config.yml" "$DFCFG/lazygit/config.yml"
create_symlink "$APP_SUPPORT/Code/User/keybindings.json" "$DFCFG/vscode/keybindings.json"
create_symlink "$APP_SUPPORT/Code/User/settings.json" "$DFCFG/vscode/settings.json"
