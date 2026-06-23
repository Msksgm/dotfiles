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
| `dot_zsh/brew_drift_check.zsh` | `~/.zsh/brew_drift_check.zsh` |
| `dot_tmux.conf` | `~/.tmux.conf` |
| `executable_dot_tmux-rename-session` | `~/.tmux-rename-session` |
| `dot_gitconfig.tmpl` | `~/.gitconfig` |
| `dot_ideavimrc` | `~/.ideavimrc` |
| `dot_config/nvim/` | `~/.config/nvim/` |
| `dot_config/karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` |
| `dot_config/mise/config.toml` | `~/.config/mise/config.toml` |
| `dot_config/helm/repositories.yaml` | `~/.config/helm/repositories.yaml` |
| `dot_config/cage/presets.yml` | `~/.config/cage/presets.yml` |
| `dot_claude/settings.json` | `~/.claude/settings.json` |
| `dot_claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `dot_claude/agents/*.md` | `~/.claude/agents/*.md` (user-level subagent) |
| `dot_claude/rules/*.md` | `~/.claude/rules/*.md` (CLAUDE.md から `@`-import するコーディング規約) |
| `dot_claude/plugins/config.json` | `~/.claude/plugins/config.json` |
| `dot_claude/plugins/known_marketplaces.json` | `~/.claude/plugins/known_marketplaces.json` |
| `dot_claude/plugins/private_installed_plugins.json` | `~/.claude/plugins/installed_plugins.json` |
| `dot_claude/plugins/private_blocklist.json` | `~/.claude/plugins/blocklist.json` |
| `dot_claude/symlink_skills` | `~/.claude/skills` → `~/.agents/skills` (symlink) |
| `dot_agents/dot_skill-lock.json` | `~/.agents/.skill-lock.json` |

> **Note (agent skills):** [`skills`](https://github.com/vercel-labs/skills) CLI で導入する skill の正本は `~/.agents/skills/` (store)。`~/.claude/skills` はそこへの symlink で、Claude Code から同じ skill を共有する。`~/.agents/.skill-lock.json` (どの GitHub ソースから入れたかの記録) を管理対象にしており、これが変わると `run_onchange_after_install-skills.sh` が `chezmoi apply` 時に各 skill を `skills add` で再取得する (Brewfile と同じ仕組み)。skill を追加/削除したら `cp ~/.agents/.skill-lock.json dot_agents/dot_skill-lock.json` で lock を source へ同期してコミットする。store 本体 (`~/.agents/skills/**`) は再生成可能なので `.chezmoiignore` で除外。

> **Note (Claude Code plugins):** プラグインは静的メタデータのみ管理する。`known_marketplaces.json` (登録マーケットプレイス) / `installed_plugins.json` (導入済み plugin の version・cache パス) / `settings.json` の `enabledPlugins` (有効化) の3点で、本体 (`~/.claude/plugins/cache/**`・`marketplaces/**`) は `.chezmoiignore` 済み・Claude Code が起動時にメタデータを見て GitHub から再 clone する。現在は公式 LSP (`gopls-lsp` / `rust-analyzer-lsp` @ `claude-plugins-official`) と [`ecc`](https://github.com/affaan-m/ECC) (`ecc@ecc`) を管理 (ecc は **Claude Code CLI ≥ v2.1.0** 必須)。メタデータが drift したら cheatsheet の `chezmoi re-add` で source へ取り込む。

## Excluded from management

以下は認証トークンや機密情報を含むため管理対象外。

| パス | 理由 |
|---|---|
| `~/.config/chezmoi/` | chezmoi 設定ファイル (`sourceDir` / `[data]` の手動変数を含む) |
| `~/.config/gh/` | GitHub CLI 認証トークン |
| `~/.config/github-copilot/` | GitHub Copilot 認証トークン |
| `~/.config/configstore/` | 各種ツールの認証情報 |
| `~/.config/nvim/lazyvim.json` | LazyVim が自動更新する既読状態ファイル |
| `~/.agents/skills/` | skills CLI が GitHub から取得する store。lock から再生成可能 (`run_onchange_after_install-skills.sh`) |
| `~/.claude.json` | Claude Code OAuth/セッション情報 (253 KB、自動 backup あり) |
| `~/.claude/sessions/` | アクティブセッション (mode 700、トークン含む) |
| `~/.claude/projects/` | プロジェクト別トランスクリプト (79 MB、機密含む) |
| `~/.claude/history.jsonl` | プロンプト履歴 (機密含む) |
| `~/.claude/paste-cache/`, `shell-snapshots/`, `image-cache/`, `file-history/` | ペースト/環境変数/画像/編集履歴キャッシュ (機密の可能性大) |
| `~/.claude/cache/`, `backups/`, `plans/`, `tasks/`, `todos/`, `session-env/`, `debug/`, `ide/` | ランタイム生成物。再生成可能 |
| `~/.claude/statsig/`, `telemetry/`, `stats-cache.json`, `mcp-needs-auth-cache.json` | テレメトリ / SDK キャッシュ |
| `~/.claude/plugins/cache/`, `plugins/data/`, `plugins/marketplaces/`, `plugins/repos/` | clone 済みプラグインリポジトリ / LSP データ。Claude Code 起動時に再生成 |

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
| `include "..."` | 自動 (関数) | `run_onchange_install-packages.sh.tmpl` / `run_onchange_after_install-skills.sh.tmpl` | source 相対のファイル内容を埋め込む。`sha256sum` と組み合わせ Brewfile / skill-lock の変更検知に使用 |

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

# Claude Code 設定を source 側に同期 (drift したとき)
chezmoi re-add ~/.claude/settings.json ~/.claude/plugins/known_marketplaces.json \
               ~/.claude/plugins/installed_plugins.json ~/.claude/plugins/blocklist.json

# brew drift: インストール済みだが Brewfile にない formula を追加
brewfile-add <formula>
brewfile-add --cask <cask>
```

> **Note (Claude Code 設定の drift):** `settings.json` の `feedbackSurveyState` や `plugins/installed_plugins.json` の git SHA / タイムスタンプは Claude Code が自動更新するため、`chezmoi diff` で差分が出ることがある。上記 `chezmoi re-add` で source 側を最新に揃えてからコミットすること。
