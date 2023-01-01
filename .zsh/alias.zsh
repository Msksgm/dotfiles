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

# .DS_Storeを削除
alias dsstore="find . -name '*.DS_Store' -type f -ls -delete"

# vscode
alias c='code'

# open
alias o='open'

# chrome
alias chrome='open /Applications/Google\ Chrome.app/'

# .env
alias export-dotenv='export $(cat .env | grep -v ^# | xargs)'

# terraform
alias tf="terraform"
alias tfi="terraform init"
alias tfp="terraform plan"
alias tfa="terraform apply"
alias tfaa="terraform apply -auto-approve"
alias tfd="terraform destroy"
alias tfda="terraform destroy -auto-approve"
alias tfv="terraform validate"
alias tff="terraform fmt -recursive"

# sail
alias sail='[ -f sail ] && bash sail || bash vendor/bin/sail'

# docker
alias d='docker'
alias dp='docker ps'
alias dc='docker compose'
alias dcu='docker compose up'
alias dcd='docker compose down'

# gnu
alias awk='gawk'
