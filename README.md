# dotfiles

Personal dotfiles managed by [chezmoi](https://www.chezmoi.io/).

## Managed files

| Source | Target |
|---|---|
| `dot_zshrc` | `~/.zshrc` |
| `dot_zshenv` | `~/.zshenv` |
| `dot_zprofile` | `~/.zprofile` |
| `dot_p10k.zsh` | `~/.p10k.zsh` |
| `dot_zsh/alias.zsh` | `~/.zsh/alias.zsh` |
| `dot_tmux.conf` | `~/.tmux.conf` |
| `executable_dot_tmux-rename-session` | `~/.tmux-rename-session` |
| `dot_gitconfig.tmpl` | `~/.gitconfig` |
| `dot_ideavimrc` | `~/.ideavimrc` |
| `dot_config/nvim/` | `~/.config/nvim/` |
| `dot_config/karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` |
| `dot_config/mise/config.toml` | `~/.config/mise/config.toml` |
| `dot_config/helm/repositories.yaml` | `~/.config/helm/repositories.yaml` |
| `dot_config/cage/presets.yml` | `~/.config/cage/presets.yml` |

## Excluded from management

以下は認証トークンや機密情報を含むため管理対象外。

| パス | 理由 |
|---|---|
| `~/.config/chezmoi/` | chezmoi 設定ファイル (`sourceDir` / `[data]` の手動変数を含む) |
| `~/.config/gh/` | GitHub CLI 認証トークン |
| `~/.config/github-copilot/` | GitHub Copilot 認証トークン |
| `~/.config/configstore/` | 各種ツールの認証情報 |
| `~/.config/nvim/lazyvim.json` | LazyVim が自動更新する既読状態ファイル |

## Template variables

`.tmpl` ファイルは chezmoi が Go template として評価する。変数は2種類:

- **手動設定が必要** — `~/.config/chezmoi/chezmoi.toml` の `[data]` に記述する。`~/.config/chezmoi/` は機密のため**このリポジトリには含まれない**ので、新規マシンでは `chezmoi apply` の前に必ず設定する (下記 step 4)。
- **chezmoi 自動提供** — 設定不要。

| 変数 | 種別 | 使用箇所 | 取得元 / 意味 |
|---|---|---|---|
| `.github_username` | 手動 | `dot_gitconfig.tmpl` | `[data] github_username` → git の `user.name` (GitHub アカウント名) |
| `.github_email` | 手動 | `dot_gitconfig.tmpl` | `[data] github_email` → git の `user.email` (GitHub に紐づく email) |
| `.chezmoi.homeDir` | 自動 | `dot_gitconfig.tmpl` | ホームディレクトリのパス (`excludesfile` に使用) |
| `.chezmoi.sourceDir` | 自動 | `run_onchange_install-packages.sh.tmpl` | source ディレクトリのパス (`Brewfile` の場所に使用) |

新たにテンプレートを追加する場合、ファイル名に `.tmpl` を付ければ上記の変数を参照できる。手動変数を増やしたときは**この表と step 4 を更新**すること。

## New machine setup

```sh
# 1. Install Homebrew (https://brew.sh)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install chezmoi and ghq
brew install chezmoi ghq

# 3. Clone dotfiles via ghq
ghq get git@github.com:Msksgm/dotfiles.git    # → ~/workspace/github.com/Msksgm/dotfiles

# 4. Configure chezmoi (sourceDir + テンプレート手動変数。詳細は "Template variables" 参照)
mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<'EOF'
sourceDir = "~/workspace/github.com/Msksgm/dotfiles"

[data]
  github_username = "Msksgm"               # → ~/.gitconfig の user.name
  github_email    = "you@example.com"      # → ~/.gitconfig の user.email
EOF

# 5. Apply dotfiles
#    run_onchange_install-packages.sh runs `brew bundle` automatically,
#    so Brewfile packages (powerlevel10k 等) もここでインストールされる
chezmoi apply
```

## chezmoi cheatsheet

```sh
# Preview what would change
chezmoi diff

# Apply all managed files
chezmoi apply

# List managed files
chezmoi managed

# Re-apply after editing source
chezmoi apply -v

# Pull remote changes and apply
chezmoi update
```
