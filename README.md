# dotfiles

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each top-level folder is a package whose contents mirror `$HOME`.

| Package     | Target                           |
| ----------- | -------------------------------- |
| `nvim`      | `~/.config/nvim`                 |
| `tmux`      | `~/.config/tmux`                 |
| `alacritty` | `~/.config/alacritty`            |
| `zsh`       | `~/.zshrc`, `~/.zshenv`, `~/.p10k.zsh` |
| `scripts`   | `~/.local/bin`                   |
| `bat`, `yazi`, `tmuxinator` | `~/.config/<name>` |

## Install (macOS, Ubuntu, Arch)

```sh
git clone git@github.com:drippypale/dotfiles.git ~/Projects/dotfiles
~/Projects/dotfiles/install.sh
```

`install.sh` installs dependencies with brew/apt/pacman, links the packages, then installs the tmux (TPM) and Neovim (lazy.nvim) plugins. Set `SKIP_DEPS=1` to only link, or `STOW_PACKAGES="nvim tmux"` to link a subset.

Existing real files at the target paths make stow abort instead of overwriting; move them aside and re-run.

Stow runs with `--no-folding`, so `~/.config/tmux` stays a real directory and plugins installed there never end up in this repo.

## Per-machine notes

- Secrets and machine-specific paths go in `~/.zshrc.local`, which `.zshrc` sources and which is never tracked. `zsh/zshrc.local.example` lists what usually belongs there.
- oh-my-zsh, powerlevel10k and the zsh plugins are cloned by `install.sh`, not stored here.
- Obsidian vault path for nvim: set `OBSIDIAN_VAULT`, otherwise the iCloud path on macOS and `~/Documents/Main-Vault` elsewhere.
- Ubuntu installs Neovim from the official release tarball because apt's version is too old for the plugin set.
