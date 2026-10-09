export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  poetry
  git
  web-search
  fzf
  tmux
  docker
  docker-compose
  kubectl
  colored-man-pages
  git-flow
  zsh-autosuggestions
  zsh-vi-mode
  nix-zsh-completions
)

export ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
export ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_USER_DEFAULT
export ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_USER_DEFAULT

source $ZSH/oh-my-zsh.sh

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

alias zshconfig="nvim ~/.zshrc"
export BAT_THEME="Catppuccin Mocha"

# ------- fzf -------------
# fzf < 0.48 (Ubuntu 24.04) has no `--zsh`; Debian ships the scripts under /usr/share/doc
if fzf --zsh &>/dev/null; then
  source <(fzf --zsh)
elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi

bindkey '^P' fzf-history-widget
fcd() {
        local dir
        dir=$(find ~ -type d -not -path '*/\.*' 2> /dev/null | fzf +m) && cd "$dir"
}

_fzf_comprun() {
    local command=$1
    shift

    case "$command" in
        cd)             fzf --preview "eza --tree --color=always {} | head -200" "$@" ;;
        z)             fzf --preview "eza --tree --color=always {} | head -200" "$@" ;;
        export|unset)   fzf --preview "eval 'echo \$' {}"                        "$@" ;;
        ssh)            fzf --preview 'dig {}'                                   "$@" ;;
        *)              fzf --preview "--preview 'bat -n --color=always --line-range :500 {}'" "$@" ;;
    esac
}

# -------- man -----------
my_man() {
     nvim "+hide Man $1"
}

alias man=my_man

# -------- PATH -----------
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$PATH:$HOME/.local/bin:$HOME/go/bin"
export PATH="$HOME/.bun/bin:$HOME/.opencode/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

export GRPC_PYTHON_BUILD_SYSTEM_OPENSSL=1
export GRPC_PYTHON_BUILD_SYSTEM_ZLIB=1
alias python="python3"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# -------- zsh-syntax-highlighting -----------
for f in /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
         /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
         /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  [[ -f $f ]] && { source $f; break; }
done
unset f

# -------- zoxide -----------
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# ------- Eza (better ls) ---------
(( $+commands[eza] )) && alias ls="eza --color=always --long --git --icons=always"

# ------- Yazi file manager ----------
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# ------- Kuber -------------
alias kx="kubectx"
alias k="kubectl"
bspod() {
  k get pod -l app=backend -l role=shell -o jsonpath='{.items[0].metadata.name}'
}

be() {
  if [[ $# -eq 0 ]]; then
    set -- bash
  fi

  k exec -it "$(bspod)" -- "$@"
}

bcp() {
  k cp "$1" "$(bspod):$2"
}

bcpf() {
  k cp "$(bspod):$1" "$2"
}

# -------- lazygit ------
alias lg='lazygit'

# -------- uv -------------
(( $+commands[uv] )) && eval "$(uv generate-shell-completion zsh)"
(( $+commands[uvx] )) && eval "$(uvx --generate-shell-completion zsh)"

# ------- pyenv -------------
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if (( $+commands[pyenv] )); then
  eval "$(pyenv init - zsh)"
  eval "$(pyenv virtualenv-init -)"
fi

# Machine-specific paths and secrets live here, outside the repo
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
