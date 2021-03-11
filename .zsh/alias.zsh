alias ..='cd ..'

# git
alias push='git push'
alias pull='git pull'
alias g='git'

# jupyter-notebook
alias jnote='jupyter-notebook'

# peco
## ブランチを簡単切り替え。git checkout lbで実行できる
alias -g lb='`git branch | peco --prompt "GIT BRANCH>" | head -n 1 | sed -e "s/^\*\s*//g"`'

## dockerコンテナに入る。deで実行できる
alias de='docker exec -it $(docker ps | peco | cut -d " " -f 1) /bin/bash'
