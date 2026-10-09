#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
read -r -a PACKAGES <<< "${STOW_PACKAGES:-nvim tmux kitty zsh scripts bat yazi}"
DRY_RUN=0
DEPS_ONLY=0
case "${1:-}" in
  --dry-run) DRY_RUN=1 ;;
  --deps-only) DEPS_ONLY=1 ;;
  "") ;;
  *) printf 'Usage: %s [--dry-run|--deps-only]\n' "$0" >&2; exit 2 ;;
esac

has_package() {
  local package
  for package in "${PACKAGES[@]}"; do
    [[ "$package" == "$1" ]] && return 0
  done
  return 1
}

validate_packages() {
  local package
  for package in "${PACKAGES[@]}"; do
    case "$package" in
      nvim|tmux|kitty|alacritty|zsh|scripts|bat|yazi|tmuxinator|hyprland) ;;
      *) warn "Unknown package: $package"; exit 2 ;;
    esac
  done
  if has_package hyprland && [[ "$(uname -s)" != Linux ]]; then
    warn "The Hyprland desktop package requires Linux"; exit 2
  fi
}
TPM_DIR="$HOME/.config/tmux/plugins/tpm"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarn:\033[0m %s\n' "$*" >&2; }

SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

detect_os() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)
      # shellcheck source=/dev/null
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
  if command -v fc-cache >/dev/null; then fc-cache -f "$dir"; fi
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
  local os="$1"
  local -a deps=(git stow) casks=()
  local package
  for package in "${PACKAGES[@]}"; do
    case "$package" in
      zsh)
        deps+=(zsh fzf zoxide eza zsh-syntax-highlighting)
        [[ "$os" != macos ]] && deps+=(curl unzip fontconfig)
        if [[ "$os" == arch ]]; then deps+=(ttf-meslo-nerd); fi
        if [[ "$os" == macos ]]; then casks+=(font-meslo-lg-nerd-font); fi ;;
      nvim)
        case "$os" in
          macos) deps+=(neovim ripgrep fd node) ;;
          arch) deps+=(neovim ripgrep fd base-devel curl unzip nodejs npm wl-clipboard xclip) ;;
          ubuntu) deps+=(ripgrep fd-find build-essential curl unzip xz-utils nodejs npm wl-clipboard xclip) ;;
        esac ;;
      tmux) deps+=(tmux) ;;
      scripts)
        deps+=(tmux fzf zoxide)
        if [[ "$os" == ubuntu ]]; then deps+=(fd-find); else deps+=(fd); fi ;;
      kitty|alacritty)
        if [[ "$os" == macos ]]; then casks+=("$package"); else deps+=("$package"); fi
        if [[ "$os" == arch ]]; then deps+=(ttf-meslo-nerd); fi
        if [[ "$os" == macos ]]; then casks+=(font-meslo-lg-nerd-font); fi
        if [[ "$os" == ubuntu ]]; then deps+=(curl unzip fontconfig); fi ;;
      bat) deps+=(bat) ;;
      yazi)
        if [[ "$os" != ubuntu ]]; then deps+=(yazi); fi ;;
      tmuxinator) deps+=(tmuxinator tmux) ;;
      hyprland)
        if [[ "$os" != arch ]]; then
          warn "Install desktop dependencies manually on this distribution (see hyprland/README.md)"
          continue
        fi
        # Preserve an existing custom/Lua-capable Hyprland installation.
        command -v Hyprland >/dev/null || deps+=(hyprland)
        deps+=(hypridle hyprlock hyprpaper waybar mako rofi dolphin
          wl-clipboard cliphist grim slurp libnotify python playerctl
          brightnessctl wireplumber pavucontrol polkit-kde-agent
          xdg-user-dirs xdg-desktop-portal-hyprland xdg-desktop-portal-gtk)
        # Vicinae and Chrome are optional applications installed separately.
        ;;
    esac
  done
  case "$os" in
    macos)
      command -v brew >/dev/null || { warn "Homebrew is required: https://brew.sh"; exit 1; }
      brew install "${deps[@]}"
      if (( ${#casks[@]} )); then brew install --cask "${casks[@]}"; fi
      ;;
    ubuntu)
      # eza and terminal emulators vary by Ubuntu release; try separately.
      local -a required=() optional=()
      for package in "${deps[@]}"; do
        case "$package" in
          eza|kitty|alacritty) optional+=("$package") ;;
          *) required+=("$package") ;;
        esac
      done
      $SUDO apt-get update
      $SUDO apt-get install -y "${required[@]}"
      for package in "${optional[@]}"; do
        $SUDO apt-get install -y "$package" || warn "Install $package manually on this Ubuntu release"
      done
      mkdir -p "$HOME/.local/bin"
      if command -v fdfind >/dev/null; then ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"; fi
      if command -v batcat >/dev/null; then ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"; fi
      has_package nvim && install_neovim_tarball
      if has_package zsh || has_package kitty || has_package alacritty; then install_nerd_font_linux; fi
      has_package yazi && warn "Install Yazi separately on Ubuntu before using its configuration"
      ;;
    arch)
      $SUDO pacman -Syu --needed --noconfirm "${deps[@]}"
      ;;
    *) warn "Unsupported OS; skipping dependency install" ;;
  esac
  return 0
}

link_packages() {
  log "Stowing: ${PACKAGES[*]}"
  stow --no-folding -d "$DOTFILES" -t "$HOME" --restow --simulate "${PACKAGES[@]}"
  stow --no-folding -d "$DOTFILES" -t "$HOME" --restow "${PACKAGES[@]}"
}

clone_if_missing() {
  [[ -d "$2" ]] || git clone --depth 1 "$1" "$2"
}

setup_zsh() {
  command -v zsh >/dev/null || return 0
  log "Installing oh-my-zsh, powerlevel10k and plugins"
  local zsh_dir="${ZSH:-$HOME/.oh-my-zsh}"
  local custom="${ZSH_CUSTOM:-$zsh_dir/custom}"
  clone_if_missing https://github.com/ohmyzsh/ohmyzsh.git "$zsh_dir"
  clone_if_missing https://github.com/romkatv/powerlevel10k.git "$custom/themes/powerlevel10k"
  clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "$custom/plugins/zsh-autosuggestions"
  clone_if_missing https://github.com/jeffreytse/zsh-vi-mode "$custom/plugins/zsh-vi-mode"
  if [[ "$(uname -s)" == Linux && "$(basename "${SHELL:-}")" != zsh ]]; then
    chsh -s "$(command -v zsh)" || warn "Could not change the login shell; run: chsh -s $(command -v zsh)"
  fi
  [[ -f "$HOME/.zshrc.local" ]] || warn "Create ~/.zshrc.local for secrets and machine paths (see zsh/zshrc.local.example)"
  return 0
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
  validate_packages
  if (( DRY_RUN )); then
    command -v stow >/dev/null || { warn "Install GNU Stow to run the dry-run"; exit 1; }
    stow --no-folding -d "$DOTFILES" -t "$HOME" --restow --simulate --verbose "${PACKAGES[@]}"
    return
  fi
  local os
  os="$(detect_os)"
  [[ "${SKIP_DEPS:-0}" == 1 ]] || install_deps "$os"
  if (( DEPS_ONLY )); then return; fi
  export PATH="$HOME/.local/bin:$PATH"
  link_packages
  if has_package zsh; then setup_zsh; fi
  if has_package tmux; then setup_tmux_plugins; fi
  if has_package nvim; then setup_nvim_plugins; fi
  if has_package bat && command -v bat >/dev/null; then bat cache --build; fi
  log "Done. Open a new terminal; tmux plugins can be refreshed with prefix + I"
}

main "$@"
