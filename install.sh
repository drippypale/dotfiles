#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES=(${STOW_PACKAGES:-nvim tmux alacritty scripts bat yazi tmuxinator})
TPM_DIR="$HOME/.config/tmux/plugins/tpm"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }

SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

detect_os() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)
      . /etc/os-release
      case " ${ID:-} ${ID_LIKE:-} " in
        *" arch "*) echo arch ;;
        *" debian "* | *" ubuntu "*) echo ubuntu ;;
        *) echo unsupported ;;
      esac
      ;;
    *) echo unsupported ;;
  esac
}

install_nerd_font_linux() {
  local dir="$HOME/.local/share/fonts"
  compgen -G "$dir/MesloLGSNerdFontMono-*" >/dev/null && return
  log "Installing MesloLGS Nerd Font"
  mkdir -p "$dir"
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip -o "$tmp/Meslo.zip"
  unzip -oq "$tmp/Meslo.zip" 'MesloLGSNerdFontMono-*' -d "$dir"
  rm -rf "$tmp"
  command -v fc-cache >/dev/null && fc-cache -f "$dir"
}

install_neovim_tarball() {
  local arch
  case "$(uname -m)" in
    x86_64) arch=x86_64 ;;
    aarch64 | arm64) arch=arm64 ;;
    *) warn "No prebuilt neovim for $(uname -m); install it manually"; return ;;
  esac
  log "Installing latest Neovim release"
  mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$arch.tar.gz" \
    | tar -xz -C "$HOME/.local/opt"
  rm -rf "$HOME/.local/opt/nvim"
  mv "$HOME/.local/opt/nvim-linux-$arch" "$HOME/.local/opt/nvim"
  ln -sf "$HOME/.local/opt/nvim/bin/nvim" "$HOME/.local/bin/nvim"
}

install_deps() {
  case "$1" in
    macos)
      command -v brew >/dev/null || { warn "Homebrew is required: https://brew.sh"; exit 1; }
      brew install git stow neovim tmux fzf zoxide fd ripgrep
      brew install --cask alacritty font-meslo-lg-nerd-font
      ;;
    ubuntu)
      $SUDO apt-get update
      $SUDO apt-get install -y git stow tmux fzf zoxide fd-find ripgrep curl unzip xz-utils build-essential xclip fontconfig
      mkdir -p "$HOME/.local/bin"
      ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
      install_neovim_tarball
      install_nerd_font_linux
      $SUDO apt-get install -y alacritty || warn "alacritty is not in this release's apt repos; install it with cargo or a PPA"
      ;;
    arch)
      $SUDO pacman -Syu --needed --noconfirm git stow neovim tmux alacritty fzf zoxide fd ripgrep base-devel curl unzip xclip ttf-meslo-nerd
      ;;
    *)
      warn "Unsupported OS; skipping dependency install"
      ;;
  esac
}

link_packages() {
  log "Stowing: ${PACKAGES[*]}"
  stow --no-folding -d "$DOTFILES" -t "$HOME" --restow "${PACKAGES[@]}"
}

setup_tmux_plugins() {
  command -v tmux >/dev/null || return 0
  [[ -d "$TPM_DIR" ]] || git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  log "Installing tmux plugins"
  "$TPM_DIR/bin/install_plugins"
}

setup_nvim_plugins() {
  command -v nvim >/dev/null || return 0
  log "Installing Neovim plugins"
  nvim --headless '+Lazy! restore' +qa
}

main() {
  local os
  os="$(detect_os)"
  [[ "${SKIP_DEPS:-0}" == 1 ]] || install_deps "$os"
  export PATH="$HOME/.local/bin:$PATH"
  link_packages
  setup_tmux_plugins
  setup_nvim_plugins
  log "Done. Open a new terminal; tmux plugins can be refreshed with prefix + I"
}

main "$@"
