# Current-machine migration checklist

Inventory taken on 2026-10-09: Arch Linux, Kitty 0.49.2, custom Lua-capable
Hyprland 0.56.0 development build. The current desktop needs software rendering,
1920x1080@60 at scale 1, and disabled blur/shadows. Its shell uses a local proxy.
Keep the proxy values, wallpaper path and rendering overrides outside Git.

- [ ] Review and merge the configuration PR.
- [x] Install GNU Stow and ShellCheck validation tooling.
- [ ] Install remaining dependencies: Neovim, tmux, eza, bat, ripgrep,
      compiler/build tools, Zsh syntax highlighting and Meslo Nerd Font.
      Use `./install.sh --deps-only` with the packages selected below.
- [ ] Back up managed configs (`.zshrc`, `.zshenv`, `.p10k.zsh`, package config
      directories and overlapping helper scripts) outside the repo.
- [ ] Preserve shell proxy exports in `~/.zshrc.local`.
- [ ] Create `~/.config/hypr/machine.lua` with current VM settings from the
      example. Preserve the current wallpaper in `hyprpaper.local.conf` and
      point `machine.hyprpaper` at it. Keep the existing session-wide
      `environment.d/hyprland.conf` VM overrides local.
- [ ] Move only conflicting managed files aside. Preserve untracked local
      override files and plugin/runtime directories.
- [ ] Run the dry-run, then install/link:

      ```sh
      STOW_PACKAGES="nvim tmux kitty zsh scripts bat yazi hyprland" ./install.sh --dry-run
      SKIP_DEPS=1 STOW_PACKAGES="nvim tmux kitty zsh scripts bat yazi hyprland" ./install.sh
      ```

- [ ] Check a new interactive Zsh session for startup errors, prompt, history
      search, vi mode and the retained proxy.
- [ ] Verify Kitty's configured font resolves to Meslo; inspect appearance in a
      fresh window and check tmux true color and pane navigation.
- [ ] Validate Hyprland with `--verify-config`; check live `hyprctl configerrors`
      after activating the config. Refresh the desktop session when convenient.
- [ ] Check Waybar workspaces, notifications, portal dialogs, clipboard history,
      screenshot capture and lock/unlock. Idle locking requires Hypridle to
      restart with the new config.

## Rollback

Use the same package selection with GNU Stow's delete mode:

```sh
stow --no-folding -d "$HOME/Projects/dotfiles" -t "$HOME" -D \
  nvim tmux kitty zsh scripts bat yazi hyprland
```

Restore the backed-up files to their original paths and restart the affected
applications or session. Leave local overrides in place or restore their saved
versions. Stow delete removes managed symlinks, not installed dependencies;
package removal is a separate decision.
