#!/usr/bin/env bash
set -euo pipefail

SRC="./src/shred.sh"
NAME="shred.sh"
TARGET_NAME="shred"   
LOCAL_BIN="$HOME/.local/bin"

usage(){ echo "Usage: $0 [--system|--user]"; exit 1; }

MODE="auto"
if [ $# -gt 1 ]; then usage; fi
if [ $# -eq 1 ]; then
  case "$1" in
    --system) MODE="system" ;;
    --user) MODE="user" ;;
    *) usage ;;
  esac
fi

if [ ! -f "$SRC" ]; then
  echo "Source $SRC not found." >&2
  exit 1
fi

OS="$(uname -s)"

install_to(){
  dest_dir="$1"
  mkdir -p "$dest_dir"
  cp -- "$SRC" "$dest_dir/$TARGET_NAME"
  chmod 755 "$dest_dir/$TARGET_NAME"
  echo "Installed $TARGET_NAME -> $dest_dir/$TARGET_NAME"
}

if [ "$MODE" = "auto" ]; then
  
  if [ "$(id -u)" -eq 0 ]; then
    MODE="system"
  else
    MODE="user"
  fi
fi

if [ "$MODE" = "system" ]; then
  
  if [ -w /usr/local/bin ] || [ "$(id -u)" -eq 0 ]; then
    install_to "/usr/local/bin"
    exit 0
  fi
  
  if [ -w /usr/bin ] || [ "$(id -u)" -eq 0 ]; then
    install_to "/usr/bin"
    exit 0
  fi
  echo "No writable system bin directory. Run with sudo or use --user." >&2
  exit 1
fi


install_to "$LOCAL_BIN"

add_path_if_missing(){
  profile="$1"
  marker="# added by shred installer"
  case "$profile" in
    "$HOME/.bashrc"|"$HOME/.profile"|"$HOME/.bash_profile"|"$HOME/.zshrc")
      if [ -f "$profile" ]; then
        if ! grep -qxF "$marker" "$profile" 2>/dev/null; then
          printf '\n%s\nexport PATH="$HOME/.local/bin:$PATH"\n' "$marker" >> "$profile"
          echo "Updated $profile to add $LOCAL_BIN to PATH"
        fi
      else
        printf '%s\nexport PATH="$HOME/.local/bin:$PATH"\n' "$marker" > "$profile"
        echo "Created $profile to add $LOCAL_BIN to PATH"
      fi
      ;;
  esac
}

case "$OS" in
  Linux*)
    add_path_if_missing "$HOME/.profile"
    add_path_if_missing "$HOME/.bashrc"
    ;;
  Darwin*)
    add_path_if_missing "$HOME/.zshrc"
    add_path_if_missing "$HOME/.bash_profile"
    ;;
  *)
    add_path_if_missing "$HOME/.profile"
    ;;
esac

echo "Done. You may need to restart your shell or run: export PATH=\"$LOCAL_BIN:\$PATH\""
