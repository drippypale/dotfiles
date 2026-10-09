# Shared interactive shell settings. Toolchains, secrets and project helpers
# belong in ~/.zshrc.local, loaded before plugins and completion setup.
[[ -o interactive ]] || return

typeset -U path PATH
path=("$HOME/.local/bin" $path)
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$ZSH/custom}"
export BAT_THEME="Catppuccin Mocha"

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt append_history share_history hist_ignore_dups hist_ignore_space
bindkey -v
export ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

# Local settings can extend plugins or initialize installed language managers.
plugins=(git web-search colored-man-pages zsh-autosuggestions zsh-vi-mode)
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Only enable plugins present on this machine. Completion plugins for optional
# developer tools can be added to `plugins` in the local file.
() {
  local plugin
  local -a available
  for plugin in "${plugins[@]}"; do
    if [[ -r "$ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh" ||
          -r "$ZSH/plugins/$plugin/$plugin.plugin.zsh" ]]; then
      available+=("$plugin")
    fi
  done
  plugins=("${available[@]}")
}

ZSH_THEME=""
if [[ -r "$ZSH_CUSTOM/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  ZSH_THEME="powerlevel10k/powerlevel10k"
fi
if [[ -r "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
else
  autoload -Uz compinit
  compinit -i
  PROMPT='%F{blue}%n@%m%f %F{cyan}%~%f %# '
fi

if [[ -z "${EDITOR:-}" ]]; then
  if (( $+commands[nvim] )); then
    EDITOR=nvim
  elif (( $+commands[vim] )); then
    EDITOR=vim
  else
    EDITOR=vi
  fi
fi
export EDITOR
export VISUAL="${VISUAL:-$EDITOR}"
alias zshconfig='${EDITOR} ~/.zshrc'
(( $+commands[python3] )) && alias python=python3
(( $+commands[lazygit] )) && alias lg=lazygit
(( $+commands[kubectl] )) && alias k=kubectl
(( $+commands[kubectx] )) && alias kx=kubectx

# fzf is initialized here rather than also enabling its oh-my-zsh plugin.
if (( $+commands[fzf] )); then
  if fzf --zsh &>/dev/null; then
    source <(fzf --zsh)
  elif [[ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -r /usr/share/doc/fzf/examples/completion.zsh ]] &&
      source /usr/share/doc/fzf/examples/completion.zsh
  elif [[ -r /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
    [[ -r /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  fi

  # zsh-vi-mode initializes lazily; restore this binding after it does so.
  _dotfiles_history_binding() {
    if (( $+widgets[fzf-history-widget] )); then
      bindkey -M emacs '^P' fzf-history-widget
      bindkey -M viins '^P' fzf-history-widget
    fi
  }
  _dotfiles_history_binding
  if (( $+functions[zvm_init] )); then
    zvm_after_init_commands+=(_dotfiles_history_binding)
  fi

  fcd() {
    local dir
    if (( $+commands[fd] )); then
      dir=$(fd --type d . "$HOME" 2>/dev/null | fzf +m)
    else
      dir=$(find "$HOME" -type d -not -path '*/.*' 2>/dev/null | fzf +m)
    fi
    [[ -n "$dir" ]] && builtin cd -- "$dir"
  }

  _fzf_comprun() {
    local cmd=$1
    shift
    case "$cmd" in
      cd|z)
        if (( $+commands[eza] )); then
          fzf --preview 'eza --tree --color=always --level=3 -- {} | head -200' "$@"
        else
          fzf --preview 'ls -la -- {}' "$@"
        fi ;;
      ssh)
        if (( $+commands[dig] )); then
          fzf --preview 'dig {}' "$@"
        else
          fzf "$@"
        fi ;;
      *)
        if (( $+commands[bat] )); then
          fzf --preview 'bat -n --color=always --line-range :500 -- {}' "$@"
        else
          fzf "$@"
        fi ;;
    esac
  }
fi

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[eza] )) && alias ls='eza --color=auto --long --git --icons=auto'

if (( $+commands[yazi] )); then
  y() {
    local tmp cwd result
    tmp=$(mktemp -t yazi-cwd.XXXXXX) || return
    command yazi "$@" --cwd-file="$tmp"
    result=$?
    cwd=$(command cat -- "$tmp")
    command rm -f -- "$tmp"
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && builtin cd -- "$cwd"
    return $result
  }
fi

(( $+commands[uv] )) && eval "$(uv generate-shell-completion zsh)"
(( $+commands[uvx] )) && eval "$(uvx --generate-shell-completion zsh)"
[[ "$ZSH_THEME" == powerlevel10k/powerlevel10k && -r "$HOME/.p10k.zsh" ]] &&
  source "$HOME/.p10k.zsh"

# Load last so highlighting observes all widgets installed above.
for _highlight in \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -r "$_highlight" ]] && { source "$_highlight"; break; }
done
unset _highlight
