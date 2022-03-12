# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source ~/powerlevel10k/powerlevel10k.zsh-theme

#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zinit-zsh/z-a-rust \
    zinit-zsh/z-a-as-monitor \
    zinit-zsh/z-a-patch-dl \
    zinit-zsh/z-a-bin-gem-node

### End of Zinit's installer chunk


# 20200615
export PATH="$HOME/.anyenv/bin:$PATH"
eval "$(anyenv init -)"
export PATH=$(brew --prefix openssl)/bin:$PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/sugimotomasaki/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/sugimotomasaki/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/sugimotomasaki/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/sugimotomasaki/google-cloud-sdk/completion.zsh.inc'; fi

export PATH="/usr/local/opt/tcl-tk/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/tcl-tk/lib"
export CPPFLAGS="-I/usr/local/opt/tcl-tk/include"
export PKG_CONFIG_PATH="/usr/local/opt/tcl-tk/lib/pkgconfig"
export PYTHON_CONFIGURE_OPTS="--with-tcltk-includes='-I/usr/local/opt/tcl-tk/include' --with-tcltk-libs='-L/usr/local/opt/tcl-tk/lib -ltcl8.6 -ltk8.6'"

# lsの色を変更
export LSCOLORS=gxfxcxdxbxegedabagacad

# peco settings
# 過去に実行したコマンドを選択。ctrl-rにバインド
function peco-select-history() {
  BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history

# search a destination from cdr list
function peco-get-destination-from-cdr() {
  cdr -l | \
  sed -e 's/^[[:digit:]]*[[:blank:]]*//' | \
  peco --query "$LBUFFER"
}

# cdr
if [[ -n $(echo ${^fpath}/chpwd_recent_dirs(N)) && -n $(echo ${^fpath}/cdr(N)) ]]; then
    autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
    add-zsh-hook chpwd chpwd_recent_dirs
    zstyle ':completion:*' recent-dirs-insert both
    zstyle ':chpwd:*' recent-dirs-default true
    zstyle ':chpwd:*' recent-dirs-max 1000
    zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/chpwd-recent-dirs"
fi

# 過去に移動したことのあるディレクトリを選択。ctrl-tにバインド
function peco-cdr() {
  local destination="$(peco-get-destination-from-cdr)"
  if [ -n "$destination" ]; then
    BUFFER="cd $destination"
    zle accept-line
  else
    zle reset-prompt
  fi
}
zle -N peco-cdr
bindkey '^t' peco-cdr


# rbenv
eval "$(rbenv init -)"

# direnv
eval "$(direnv hook zsh)"
show_virtual_env() {
  if [ -n "$VIRTUAL_ENV" ]; then
    echo "($(basename $VIRTUAL_ENV))"
  fi
}
PS1='$(show_virtual_env)'$PS1
# tmuxのために.envrcがあるときにreloadするように設定
if [ -e ".envrc" ]; then
    direnv reload
fi

# source /Users/sugimotomasaki/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# 補完
zinit light zsh-users/zsh-autosuggestions

# シンタックスハイライト
zinit light zdharma/fast-syntax-highlighting

# Ctrl+r でコマンド履歴を検索
# zinit light zdharma/history-search-multi-word


bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^F" forward-char
bindkey "^B" backward-char
bindkey "^D" delete-char-or-list
bindkey "^Y" yank


# mysql 5.7.31
export PATH=/usr/local/mysql/bin:$PATH

ZSHHOME="${HOME}/dotfiles/.zsh"

if [ -d $ZSHHOME -a -r $ZSHHOME -a \
     -x $ZSHHOME ]; then
    for i in $ZSHHOME/*; do
        [[ ${i##*/} = *.zsh ]] &&
            [ \( -f $i -o -h $i \) -a -r $i ] && . $i
    done
fi

# For phpenv install php

# bison
export PATH="/usr/local/opt/bison/bin:$PATH"

# bzip2
export PATH="/usr/local/opt/bzip2/bin:$PATH"
# For compilers to find bzip2
# export LDFLAGS="-L/usr/local/opt/bzip2/lib"
# export CPPFLAGS="-I/usr/local/opt/bzip2/include"

# libiconv
export PATH="/usr/local/opt/libiconv/bin:$PATH"
# For compilers to find libiconv
# export LDFLAGS="-L/usr/local/opt/libiconv/lib"
# export CPPFLAGS="-I/usr/local/opt/libiconv/include"

# libedit
export LDFLAGS="-L/usr/local/opt/libedit/lib"
export CPPFLAGS="-I/usr/local/opt/libedit/include"
# For pkg-config to find libedit
# export PKG_CONFIG_PATH="/usr/local/opt/libedit/lib/pkgconfig"

# libxml2
export PATH="/usr/local/opt/libxml2/bin:$PATH"

export CFLAGS="-Wno-error=implicit-function-declaratiion -DU_DEFINE_FALSE_AND_TRUE=1"
export CXXFLAGS="-Wno-error=implicit-function-declaratiion -DU_DEFINE_FALSE_AND_TRUE=1"

export PATH="/usr/local/opt/openssl/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"

export GOPATH=$HOME/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# gcloud
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
source '/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'