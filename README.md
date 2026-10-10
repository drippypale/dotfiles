# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level
package mirrors `$HOME`; Stow links files using `--no-folding`, keeping plugin
and runtime directories out of this repo.

| Package | Target |
| --- | --- |
| `zsh` | `~/.zshrc`, `~/.zshenv`, `~/.p10k.zsh` |
| `kitty`, `alacritty` | `~/.config/<terminal>` |
| `nvim`, `tmux` | `~/.config/<name>` |
| `scripts` | `~/.local/bin` |
| `bat`, `yazi`, `tmuxinator` | `~/.config/<name>` |
| `git` | `~/.gitconfig` |
| `lazygit`, `htop` | `~/.config/<name>` |
| `hyprland` (opt-in, Linux) | Hyprland, Waybar, Mako, portal configs and desktop scripts |
| `i3` (opt-in, Linux/X11) | i3, picom |

## Install

```sh
git clone git@github.com:drippypale/dotfiles.git ~/Projects/dotfiles
cd ~/Projects/dotfiles
./install.sh
```

The default packages are `nvim tmux kitty zsh scripts bat yazi`. Alacritty
remains available, and the existing project-specific tmuxinator configs are
opt-in. Select a subset or add the Linux desktop explicitly:

```sh
STOW_PACKAGES="zsh kitty" ./install.sh
STOW_PACKAGES="nvim tmux kitty zsh scripts bat yazi hyprland" ./install.sh
```

Dependencies are installed with brew/apt/pacman. Arch installation performs a
system upgrade. Desktop dependencies are automated on Arch; on other Linux
distributions install them manually (see [desktop notes](hyprland/README.md)).
Ubuntu uses the official Neovim tarball; Yazi and lazygit require a separate
installation (lazygit isn't in Ubuntu's apt repos).
Chrome and Vicinae are optional desktop applications installed separately.

Only selected packages get their dependencies and initialization. Zsh installs
Oh My Zsh, Powerlevel10k, autosuggestions and vi mode; tmux installs TPM plugins;
Neovim restores its locked plugins; bat builds its theme cache.

```sh
# Install dependencies without linking or initializing plugins.
STOW_PACKAGES="zsh kitty" ./install.sh --deps-only
# Inspect links and conflicts without making changes (requires Stow).
STOW_PACKAGES="zsh kitty" ./install.sh --dry-run
# Use dependencies already installed on the machine.
SKIP_DEPS=1 STOW_PACKAGES="zsh kitty" ./install.sh
```

Existing real files cause Stow to abort. Back them up outside the repo, move
conflicting files aside, and repeat the dry-run before linking. The installer
also simulates Stow before it links; it never adopts or overwrites existing
configs. Documentation and local override examples are not installed.

## Shared settings and local overrides

- **Zsh:** common history, prompt, vi mode (`jk`), Git helpers and guarded
  fzf/zoxide/eza/Yazi integrations. `Ctrl+P` searches history when fzf is
  installed. `~/.zshrc.local` loads before plugins and completions; use
  [the example](zsh/zshrc.local.example) for toolchains, extra plugins, secrets,
  proxy settings and cluster-specific helpers. Non-interactive shells only
  add `~/.local/bin`; they do not initialize Rust or other toolchains.
- **Kitty:** Catppuccin Mocha, MesloLGS Nerd Font Mono at 15pt, 60% background
  opacity and a blinking block cursor, translated from Alacritty. Padding is
  7.5pt (approximately 10px at 96 DPI). Window decorations are hidden with
  `titlebar-only`; Option acts as Alt on macOS. Add machine adjustments in
  `~/.config/kitty/local.conf`. Keep Kitty's native `xterm-kitty` TERM; tmux
  advertises `tmux-256color` and recognizes Kitty RGB support. Alacritty's
  vi-mode/search/dim color settings have no direct shared mapping. Linux blur
  is supplied by the compositor and can be disabled in the desktop local file.
- **Alacritty:** add machine adjustments (opacity, font size, etc.) in
  `~/.config/alacritty/alacritty.local.toml`; it's imported last, and a
  missing file is fine.
- **Hyprland:** see [desktop notes](hyprland/README.md). Monitors, application
  overrides and VM workarounds belong in `~/.config/hypr/machine.lua`.
- **i3:** kept as a reference/fallback X11 setup, not actively used day to
  day. Monitor names, the wallpaper path and per-app workspace assignments
  are specific to the machine it was written on -- adjust them before using
  it elsewhere.
- **tmux:** project shortcuts belong in `~/.config/tmux/tmux.local.conf`, loaded
  before TPM. Generic session selection remains in the shared config.
- **Neovim:** set `OBSIDIAN_VAULT` for the local vault. The existing fallback is
  the iCloud path on macOS and `~/Documents/Main-Vault` elsewhere.

Local override files are ignored by Git. Installations and backups should stay
outside the repository. See the [current-machine checklist](hyprland/machine-setup.md)
for the migration order and rollback instructions.
