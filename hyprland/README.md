# Hyprland desktop

This package preserves the current machine's **Lua configuration API**, including
Super-based tiling shortcuts, numbered workspaces, named Browser/Terminal
workspaces, and Super or Alt+Ctrl shortcuts for those named workspaces.

It was validated with Hyprland `0.56.0`, development commit
`5a78b5e927345860a27e2893bf894f97ee620c48` (2026-10-06). A distribution build
with only the older `.conf` syntax cannot load `hyprland.lua`. Check your build
before enabling the package. The installer preserves an existing Hyprland binary.

The package also includes Hypridle, Hyprlock, Hyprpaper, Waybar, Mako, portal
preferences, clipboard/screenshot/lock helpers, and the workspace-status daemon
used by this machine's Waybar configuration. It does not change your display
manager or how you start the desktop session.

## Setup

Install a Lua-capable Hyprland build and these desktop dependencies:

- `hypridle`, `hyprlock`, `hyprpaper`, `waybar`, `mako`, `rofi`, `dolphin`
- `wl-clipboard`, `cliphist`, `grim`, `slurp`, `libnotify`, Python 3
- `wireplumber`, `playerctl`, `brightnessctl`, `pavucontrol`
- `xdg-user-dirs`, a Polkit authentication agent, D-Bus/systemd user session
- `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk`

Arch dependencies are installed when you select this package. The default app
choices use Chrome and Vicinae, which you install separately; Rofi remains the
Alt+R launcher. You can override apps in the local settings file.

1. Back up existing desktop configs and helper scripts outside this repo.
2. Copy `machine.lua.example` to `~/.config/hypr/machine.lua` and enable the
   settings this machine needs. No local file is required for shared defaults.
3. Use a preferred monitor mode by default, or set `monitor_mode`/`monitor_scale`.
   Put VM rendering workarounds in this file; keep blur and shadows disabled on
   the current VM. Other machines use blur and shadows by default.
4. For wallpaper, copy the shared `hyprpaper.conf` to
   `~/.config/hypr/hyprpaper.local.conf`, add real `preload` and `wallpaper` paths,
   and set the `hyprpaper` command in `machine.lua` as shown in the example.
5. Move conflicting managed files aside, then run:

   ```sh
   STOW_PACKAGES=hyprland ./install.sh --dry-run
   SKIP_DEPS=1 STOW_PACKAGES=hyprland ./install.sh
   Hyprland --verify-config -c "$HOME/.config/hypr/hyprland.lua"
   ```

The desktop startup helper exports `~/.local/bin` to child processes, imports
the session environment for portals, starts clipboard history and idle locking,
and chooses an installed KDE/GNOME Polkit agent.

Changes to startup processes and environment may require a fresh desktop
session. After reviewing config errors, reload the compositor and restart
Waybar/Hypridle/Hyprpaper when convenient. Avoid starting duplicate daemons.

Useful desktop keys: Alt+Q opens Kitty, Alt+Shift+V opens clipboard history,
Print takes a region screenshot and copies it, and Alt+Shift+L locks the session.

## Local lock screen settings

The `hypr-lock` helper uses `~/.config/hypr/hyprlock.local.conf` when present
(or the equivalent under `XDG_CONFIG_HOME`). Otherwise it uses Hyprlock's
default config. This applies to both the lock shortcut and Hypridle.

For a VM where GPU screenshot capture fails, create that local file with:

```ini
source = ~/.config/hypr/hyprlock.conf

general {
    screencopy_mode = 1
}
```

This keeps the shared appearance and uses CPU screenshot capture on this
machine. No compositor reload is needed; the next lock uses the new settings.
The local file is ignored by Git. Launching `hyprlock` directly bypasses this
helper; use `hypr-lock` or pass `--config` explicitly to test local settings.
