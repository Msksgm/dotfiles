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
| `dot_zsh/github-auth.zsh` | `~/.zsh/github-auth.zsh`（org ごとの App 名を使い、`git()` / `gh()` / `ghq()` で ghtkn の認証を選択する。既存の `~/.zsh/*.zsh` 読み込みで関数を定義する） |
| `dot_zsh/herdr.zsh` | `~/.zsh/herdr.zsh`（herdr 用のシェル設定。自分の pane ID を herdr にカスタムトークンとして報告する `_herdr_report_pane_id` を定義する。`~/.zsh/*.zsh` の source は `mise activate` より前で herdr が PATH に無いため、**定義だけを置き呼び出しは `dot_zshrc` の mise activate 直後**に置いている） |
| `dot_tmux.conf` | `~/.tmux.conf` |
| `executable_dot_tmux-rename-session` | `~/.tmux-rename-session` |
| `dot_gitconfig.tmpl` | `~/.gitconfig` |
| `dot_ideavimrc` | `~/.ideavimrc` |
| `dot_crit.config.json` | `~/.crit.config.json`（crit のグローバル設定。`plan_approve_mode` で plan 承認後の Claude Code permission mode を指定する。プロジェクト側 `.crit.config.json` からは上書き不可） |
| `dot_config/nvim/` | `~/.config/nvim/` |
| `dot_config/karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` |
| `dot_config/mise/config.toml.tmpl` | `~/.config/mise/config.toml`（言語ランタイム + aqua バックエンドの主要 CLI ツール群。aqua 未登録のツールは github バックエンド等を使い、npm 配布の WXT は npm バックエンドで管理する。**private tool はここに書かない** — lockfile `mise.lock` を追跡しているため、下記 `config.local.toml` に隔離する） |
| `dot_config/mise/private_config.local.toml.tmpl` | `~/.config/mise/config.local.toml`（private tool 専用の machine-local config。mode 0600。`private_tool_repo` を設定したマシンでのみ展開され、lockfile は `mise.local.lock` に分離されて追跡されない） |
| `dot_config/mise/private_mise.lock` | `~/.config/mise/mise.lock`（mise の lockfile。全ツールの version / URL / checksum を複数プラットフォーム分固定して再現性を担保する。mode 0600。**生成物なので手で編集せず** `mise lock -g` → `cp` で同期する。手順は下記 "mise lockfile の更新" 参照） |
| `dot_config/helm/repositories.yaml` | `~/.config/helm/repositories.yaml` |
| `dot_config/cage/presets.yml` | `~/.config/cage/presets.yml` |
| `dot_config/herdr/config.toml` | `~/.config/herdr/config.toml`（キーバインドを `dot_tmux.conf` に合わせた herdr 設定。prefix=`C-j`、分割 `\|`/`-`、ペイン移動 h/j/k/l、タブ移動 `C-h`/`C-l`、デタッチ `prefix+d`、workspace 作成 `prefix+Shift+C`、workspace リネーム `prefix+Space`、pane を新 tab に切り出し `prefix+!`（tmux の break-pane 相当。組み込みアクションが無いため `herdr pane move --new-tab` を shell command で呼ぶ）。加えて `[ui.sidebar.agents]` で左サイドバーの agent 行に pane ID (`wG:pB`) を表示する。この `$pane_id` はカスタムトークンで、**値の供給は `dot_zsh/herdr.zsh` に依存する** — 片方だけ消すと ID が空欄になる） |
| `dot_config/herdr/executable_rename-workspace.sh` | `~/.config/herdr/rename-workspace.sh`（実行ビット付き。focused workspace を git リポジトリ名にリネームする。tmux の `~/.tmux-rename-session` の herdr 版で、config.toml の `[[keys.command]]` から `prefix+Space` で呼ぶ） |
| `dot_codex/modify_private_config.toml` | `~/.codex/config.toml`（mode 0600 の chezmoi `modify_` スクリプト。model / reasoning effort / personality / approval / service tier / `.agents`・`.codex`・`.git` 書き込みを含む `workspace-agents-write` permission profile だけを強制し、Codex が書き換える project trust / notify / Desktop / plugin / MCP / hook 等は実ファイルから保持する） |
| `dot_codex/AGENTS.md.tmpl` | `~/.codex/AGENTS.md`（全プロジェクト共通の Codex 指示。CLI ツール管理ルールを `.chezmoitemplates/cli-tool-management.md` から展開） |
| `dot_claude/modify_settings.json.tmpl` | `~/.claude/settings.json`（chezmoi `modify_` スクリプト。自分が管理するキー（env/permissions/model/hooks/deny 等）だけ強制し、Claude Code が実行時に書き換えるキー（`enabledPlugins`/`extraKnownMarketplaces`/`feedbackSurveyState`）は実ファイルから保持してドリフトを防ぐ。herdr フックパスは `{{ .chezmoi.homeDir }}` で展開） |
| `dot_claude/hooks/executable_herdr-agent-state.sh` | `~/.claude/hooks/herdr-agent-state.sh`（実行ビット付き。settings.json の SessionStart フックが呼ぶ herdr の Claude 連携スクリプト。**herdr が自動管理し integration 更新時に上書きするため source はスナップショット**。更新時は再 `cp` で同期する） |
| `dot_claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `dot_claude/agents/*.md` | `~/.claude/agents/*.md` (user-level subagent) |
| `dot_claude/rules/*.md` | `~/.claude/rules/*.md` (CLAUDE.md から `@`-import するコーディング規約) |
| `dot_claude/rules/tool-management.md.tmpl` | `~/.claude/rules/tool-management.md`（Claude Code 用の CLI ツール管理ルール。同じ共通テンプレートから展開） |
| `dot_claude/rules/golang/*.md` | `~/.claude/rules/golang/*.md` (Go 固有ルール。`@`-import せず参照用) |
| `dot_claude/rules/kotlin/*.md` | `~/.claude/rules/kotlin/*.md` (Kotlin 固有ルール。`@`-import せず参照用) |
| `dot_claude/plugins/config.json` | `~/.claude/plugins/config.json` |
| `dot_claude/plugins/private_blocklist.json` | `~/.claude/plugins/blocklist.json` |
| `dot_claude/symlink_skills` | `~/.claude/skills` → `~/.agents/skills` (symlink) |
| `dot_agents/dot_skill-lock.json` | `~/.agents/.skill-lock.json` |
| `dot_agents/skills-local/pair-programming/**` | `~/.agents/skills-local/pair-programming/`（日本語・ヒント中心のペアプロ用 skill。インストーラ経由で `~/.agents/skills/pair-programming/` にも展開。明示呼び出し専用: Codex は `$pair-programming`、Claude Code は `/pair-programming`） |
| `dot_agents/skills-local/codex-version-update/SKILL.md` | `~/.agents/skills-local/codex-version-update/SKILL.md`（この dotfiles の mise/aqua 管理に沿って Codex CLI の version pin、公式 changelog 確認、lock 同期、導入版検証を進める skill。インストーラ経由で `~/.agents/skills/codex-version-update/` にも展開） |
| `dot_agents/skills-local/pr-critical-review/**` | `~/.agents/skills-local/pr-critical-review/`（根拠付きの PR トリアージを行う Markdown 専用 skill。未採用の図解仕様は `references/` に保管し、インストーラ経由で `~/.agents/skills/pr-critical-review/` にも展開） |
| `dot_agents/skills-local/review-io-impact/**` | `~/.agents/skills-local/review-io-impact/`（影響調査とテストカバレッジ確認。レポート書式・crit手順は必要時だけ `references/` から読み込む。インストーラ経由で `~/.agents/skills/review-io-impact/` にも展開） |
| `dot_agents/skills-local/impact-diagram/SKILL.md` | `~/.agents/skills-local/impact-diagram/SKILL.md`（調査済みの影響経路を全体図・入口別図・出口図に分割して描画。インストーラ経由で `~/.agents/skills/impact-diagram/` にも展開） |
| `dot_agents/skills-local/svg-diagram/**` | `~/.agents/skills-local/svg-diagram/`（SKILL.md + `components/` `examples/` の HTML テンプレート。インストーラ経由で `~/.agents/skills/svg-diagram/` にも展開） |

> **Note (Codex config):** `~/.codex/config.toml` は手動設定と Codex 所有の実行時状態が混在するため、ファイル全体をスナップショットせず `modify_private_config.toml` で管理対象キーだけを置換する。未管理の root key と table はそのまま保持されるので、Codex が project trust・通知先・Desktop 設定・plugin/MCP/hook 状態を更新しても `chezmoi diff` の対象にならない。`~/.codex` には認証情報・会話履歴・shell snapshot もあるため、**ディレクトリ全体を `chezmoi add ~/.codex` しない**。

> **Note (共通 CLI ツール管理ルール):** `.chezmoitemplates/cli-tool-management.md` を正本とし、`~/.codex/AGENTS.md` と `~/.claude/rules/tool-management.md` の両方へ同じ内容を展開する。ルール変更時は各出力テンプレートではなく共通テンプレートを編集する。

> **Note (agent skills):** skill の導入チャネルは2種類ある。① **GitHub lock チャネル**: [`skills`](https://github.com/vercel-labs/skills) CLI で導入する skill の正本は `~/.agents/skills/` (store)。`~/.claude/skills` はそこへの symlink で、Claude Code から同じ skill を共有する。`~/.agents/.skill-lock.json` (どの GitHub ソースから入れたかの記録) を管理対象にしており、これが変わると `run_onchange_after_install-skills.sh` が `chezmoi apply` 時に各 skill を `skills add` で再取得する (Brewfile と同じ仕組み)。skill を追加/削除したら `cp ~/.agents/.skill-lock.json dot_agents/dot_skill-lock.json` で lock を source へ同期してコミットする。② **自作 skill チャネル**: `dot_agents/skills-local/<name>/` に `SKILL.md`（とサポートファイル）を置き、`run_onchange_after_install-local-skills.sh` が `chezmoi apply` 時に `~/.agents/skills/<name>/` へコピーする。GitHub チャネルは lock 外のフォルダを削除しないため両チャネルは共存できる。store 本体 (`~/.agents/skills/**`) は再生成可能なので `.chezmoiignore` で除外（自作スキルの source は `dot_agents/skills-local/` に残る）。自作 skill を**削除**するときは source から消すだけでは足りず、`run_onchange_after_install-local-skills.sh.tmpl` の `REMOVED_SKILLS` 配列（store 側の実体を除去）と `.chezmoiremove`（`~/.agents/skills-local/` 側の残骸を除去。残すと毎回再インストールされる）の2箇所に追記する。

> **Note (Claude Code plugins):** プラグインの導入は `run_onchange_after_install-claude-plugins.sh.tmpl` の **inline manifest**（`MARKETPLACES` / `PLUGINS` 配列）が唯一の source of truth。`chezmoi apply` 時にこのスクリプトが `claude plugin marketplace add` + `claude plugin install` を冪等に流し、marketplace の clone と cache 本体を再生成する（skills store と同じ「ignore して run_onchange で再生成」方式）。Claude Code が実行時に所有する `known_marketplaces.json` / `installed_plugins.json` は `.chezmoiignore` 済みで**追跡しない**（タイムスタンプ等のドリフトが出ない）。有効化状態 `enabledPlugins` は `modify_settings.json.tmpl` が新規マシン用に seed し、以降は Claude Code の値を保持する。現在は公式 LSP (`gopls-lsp` / `rust-analyzer-lsp` @ `claude-plugins-official`) と [`ecc`](https://github.com/affaan-m/ECC) (`ecc@ecc`)、[`crit`](https://github.com/tomasz-tomczyk/crit) (`crit@crit`) を管理 (ecc は **Claude Code CLI ≥ v2.1.0** 必須)。プラグインを増減するときは manifest 配列を編集するだけ（JSON への手動反映や `chezmoi re-add` は不要）。

> **Note (Homebrew 管理の CLI):** `Brewfile.tmpl` の「CLI・シェル環境（Homebrew 管理）」に formula と CLI の cask をまとめ、各定義行の右側に Homebrew 管理理由を記載する。既存方針・設定・配布情報から理由を確認し、特定できないものは「個別の管理理由は未確認」と明記する。`diff-pdf` は [aqua 標準レジストリ](https://github.com/aquaproj/aqua-registry)に未登録で、[公式配布](https://github.com/vslavik/diff-pdf#obtaining-the-binaries)に macOS 用バイナリがないため、[Homebrew formula](https://formulae.brew.sh/formula/diff-pdf) で Poppler・Cairo・wxWidgets 等の依存ライブラリとともに管理する。通常の `chezmoi apply` で `brew bundle` が実行され、ほかの Brewfile エントリとともにインストール・更新される。

> **Note (op / 1Password CLI):** `op` は「single-binary CLI は原則 aqua (mise)」方針の**例外**で、`Brewfile.tmpl` の `cask "1password-cli"` で管理する。aqua registry の `1password/cli` は配布元が GitHub release ではなく `cache.agilebits.com` のため `type: http` 扱いで `repo_owner`/`repo_name` を持たず、mise ではバージョン一覧を引けない (`ls-remote` / `latest` / `"latest"` 指定が不可 → 更新検知が効かず手動追従になる)。上流が digest を公開していないので lockfile にも checksum が載らない。aqua を選ぶ利点が両方とも成立しない一方、資格情報ツールは追従が遅れるほうが痛いため brew に置いている (cask は `op` の zsh 補完も同梱する)。バージョン追従は `brew upgrade` に任せる。

> **Note (二重チャネル管理ツール):** crit / herdr は CLI（mise）と Claude 連携（plugin / skill / hook）の**複数チャネルで同じツールを管理**している。CLI のバージョンだけ上げると連携側が古いままズレるため、更新時は両方を揃えること。対応表と更新手順は `CLAUDE.md` の「二重チャネル管理ツール（CLI + Claude 連携）」を参照。

## Excluded from management

以下はリポジトリ専用のメタファイル、認証トークン・機密情報、アプリが所有する実行時状態のため管理対象外。

| パス | 理由 |
|---|---|
| `AGENTS.md`（リポジトリ直下） | この dotfiles の chezmoi 適用ルールの正本。Git で管理し、home には展開しない |
| `~/.config/chezmoi/` | chezmoi 設定ファイル (`sourceDir` / `[data]` の手動変数を含む) |
| `~/.config/gh/` | GitHub CLI 認証トークン |
| `~/.config/github-copilot/` | GitHub Copilot 認証トークン |
| `~/.config/configstore/` | 各種ツールの認証情報 |
| `~/.config/nvim/lazyvim.json` | LazyVim が自動更新する既読状態ファイル |
| `~/.config/mise/mise.local.lock` | `config.local.toml`（private tool）の lockfile。private repo 名とリリースアセット URL を含むため public repo に置けない。`mise lock -g` を実行すると（`mise.lock` と一緒に）各マシンで自動生成される |
| `~/.agents/skills/` | skills CLI が GitHub から取得する store。lock から再生成可能 (`run_onchange_after_install-skills.sh`) |
| `~/.codex/auth.json`, `.codex-global-state.json*`, `installation_id` | Codex の認証・インストール・アプリ状態。機密またはマシン固有 |
| `~/.codex/history.jsonl`, `session_index.jsonl`, `sessions/`, `archived_sessions/`, `attachments/`, `shell_snapshots/` | 会話・添付・実行環境の履歴。機密情報を含む可能性が高い |
| `~/.codex/*.sqlite*`, `cache/`, `log/`, `tmp/`, `.tmp/`, `plugins/cache/`, `skills/.system/` | Codex とpluginが生成するDB・cache・log・組み込みskill。再生成可能 |
| `~/.codex/rules/`, `~/.codex/automations/` | rules は一時的なコマンド許可、automations はmachine-localな定義・memoryのため追跡しない |
| `~/.claude.json` | Claude Code OAuth/セッション情報 (253 KB、自動 backup あり) |
| `~/.claude/sessions/` | アクティブセッション (mode 700、トークン含む) |
| `~/.claude/projects/` | プロジェクト別トランスクリプト (79 MB、機密含む) |
| `~/.claude/history.jsonl` | プロンプト履歴 (機密含む) |
| `~/.claude/paste-cache/`, `shell-snapshots/`, `image-cache/`, `file-history/` | ペースト/環境変数/画像/編集履歴キャッシュ (機密の可能性大) |
| `~/.claude/cache/`, `backups/`, `plans/`, `tasks/`, `todos/`, `session-env/`, `debug/`, `ide/` | ランタイム生成物。再生成可能 |
| `~/.claude/statsig/`, `telemetry/`, `stats-cache.json`, `mcp-needs-auth-cache.json` | テレメトリ / SDK キャッシュ |
| `~/.claude/plugins/cache/`, `plugins/data/`, `plugins/marketplaces/`, `plugins/repos/` | clone 済みプラグインリポジトリ / LSP データ。Claude Code 起動時に再生成 |
| `~/.claude/plugins/known_marketplaces.json`, `plugins/installed_plugins.json` | Claude Code が実行時に所有・書き換える（タイムスタンプ等が drift する）。`run_onchange_after_install-claude-plugins.sh` の manifest から `claude plugin install` で再生成 |

## Template variables

`.tmpl` ファイルは chezmoi が Go template として評価する。変数は2種類:

- **手動設定が必要** — `~/.config/chezmoi/chezmoi.toml` の `[data]` に記述する。`~/.config/chezmoi/` は機密のため**このリポジトリには含まれない**ので、新規マシンでは `chezmoi apply` の前に必ず設定する (下記 step 4)。
- **chezmoi 自動提供** — 設定不要。

| 変数 | 種別 | 使用箇所 | 取得元 / 意味 |
|---|---|---|---|
| `.github_username` | 手動 | `dot_gitconfig.tmpl` | `[data] github_username` → git の `user.name` (GitHub アカウント名) |
| `.github_email` | 手動 | `dot_gitconfig.tmpl` | `[data] github_email` → git の `user.email` (GitHub に紐づく email) |
| `.ghtkn_apps` | 手動 (任意) | `dot_config/ghtkn/private_ghtkn.yaml.tmpl` | `[[data.ghtkn_apps]]` の App 名・Client ID。設定したマシンのみ `ghtkn.yaml` を生成 |
| `.private_tool_repo` | 手動 (任意) | `dot_config/mise/private_config.local.toml.tmpl` | private GitHub repo のツールの `owner/repo`。github バックエンドの tool spec に使用。設定時のみ導入 (hasKey ゲート) |
| `.private_tool_version` | 手動 (任意) | `dot_config/mise/private_config.local.toml.tmpl` / `run_onchange_after_install-mise-tools.sh.tmpl` | private tool の tool spec のバージョン。repo 名と同様に public repo へ残さないため注入する。バージョンを上げるときはこの値を書き換えて `chezmoi apply` するだけでよい (dotfiles のコミット不要) |
| `.op_account` | 手動 (任意) | `run_onchange_after_install-mise-tools.sh.tmpl` | op-vault の `OP_ACCOUNT` (1Password アカウント識別子) |
| `.private_tool_token_ref` | 手動 (任意) | `run_onchange_after_install-mise-tools.sh.tmpl` | private repo を読める GitHub PAT の `op://<Vault>/<Item>/<field>` 参照 |
| `install_orbstack` | 手動 (任意) | `Brewfile.tmpl` | 設定したマシンでのみ `cask "orbstack"` を install (`hasKey` ゲート) |
| `install_docker_desktop` | 手動 (任意) | `Brewfile.tmpl` | 設定したマシンでのみ `cask "docker-desktop"` を install (`hasKey` ゲート) |
| `.chezmoi.homeDir` | 自動 | `dot_gitconfig.tmpl` | ホームディレクトリのパス (`excludesfile` に使用) |
| `.chezmoi.sourceDir` | 自動 | `run_onchange_install-packages.sh.tmpl` | source ディレクトリのパス (`Brewfile.tmpl` の場所に使用) |
| `include "..."` | 自動 (関数) | `run_onchange_install-packages.sh.tmpl` / `run_onchange_after_install-skills.sh.tmpl` / `run_onchange_after_install-local-skills.sh.tmpl` / `run_onchange_after_install-mise-tools.sh.tmpl` | source 相対のファイル内容を埋め込む。`sha256sum` と組み合わせ Brewfile.tmpl / skill-lock / 自作 skill / mise config (`config.toml.tmpl`・`private_config.local.toml.tmpl`・`private_mise.lock`) の変更検知に使用 |

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
  # 以下4変数は private GitHub repo のツールを mise で入れるマシンでだけ設定（任意）。
  # 詳細は下記 "Private tool" 参照。4つはセットで必要。
  private_tool_repo       = "<owner>/<repo>"
  private_tool_version    = "<version>"    # 例: "1.2.3"
  op_account              = "<1Password アカウント識別子>"
  private_tool_token_ref  = "op://<Vault>/<Item>/<field>"
  # container runtime cask はマシンごとに入れ分ける（任意・どちらか一方 or 両方）。
  # 設定したキーの cask だけが `brew bundle` で install される。
  # install_orbstack       = true
  # install_docker_desktop = true
EOF

# 5. Apply dotfiles
#    run_onchange_install-packages.sh runs `brew bundle` automatically,
#    so Brewfile packages (powerlevel10k 等) もここでインストールされる
#    mise.lock も chezmoi 管理下なので、mise のツールは全マシンで同一 version/checksum で入る
chezmoi apply
```

## GitHub 認証（ghtkn）

共通設定と説明コメントは `dot_config/ghtkn/private_ghtkn.yaml.tmpl` で管理する。App 名・Client ID は Git 管理対象外の `~/.config/chezmoi/chezmoi.toml` に次の形式で追記する。

```toml
[[data.ghtkn_apps]]
name = "example-org/read"
client_id = "<read App の Client ID>"

[[data.ghtkn_apps]]
name = "example-org/write"
client_id = "<write App の Client ID>"
```

既存設定を移行するときは `apps` の名前・Client ID・並び順を引き継ぐ。App ごとの説明は `chezmoi.toml` の `name` 行に TOML コメントとして残せる。コメントは生成先の YAML には出力されない。先頭の App はデフォルトとして使われる。`ghtkn_apps` が未設定のマシンでは `.chezmoiignore` により設定ファイルを管理対象から外し、既存ファイルを保持する。空の配列を設定した場合はテンプレートの評価をエラーにする。

ローカルデータを設定後、`chezmoi diff ~/.config/ghtkn/ghtkn.yaml` で確認し、ユーザーが `chezmoi apply ~/.config/ghtkn/ghtkn.yaml` を実行する。生成先は `~/.config/ghtkn/ghtkn.yaml` で、`private_` 属性により権限は `0600` となる。生成後の変更は共通設定なら source、App 設定なら `chezmoi.toml` を編集する。

`~/.zsh/github-auth.zsh` の共通関数と `~/.gitconfig` の GitHub HTTPS 用 credential helper を使う。Git は `ghtkn git-credential`、gh は `ghtkn exec` で認証する。GitHub に限って既存 helper を空の設定でリセットし、`useHttpPath = true` でリポジトリの path を helper に渡す。[ghtkn 公式仕様](https://github.com/suzuki-shunsuke/ghtkn/blob/main/docs/git-credential-helper.md)

org ごとの `mise.toml` はこの dotfiles の管理対象外。例えば、`~/workspace/github.com/example-org/mise.toml` に次を設定し、mise を有効化した Zsh で配下のリポジトリへ移動する。

```toml
[env]
GHTKN_GIT_APP_READ = "example-org/read"
GHTKN_GIT_APP_WRITE = "example-org/write"
```

値は ghtkn に登録した `apps[].name` と完全に一致させる。各 org の read / write App の登録・権限・インストールと `ghtkn auth` による認証は利用前に用意する。既存設定を使う場合も、App 名の不一致や read App の未登録を確認する。切替対象の owner を `git_owner` / `git_owners` に固定すると環境変数より優先されるため、固定割当は設定しない。[App の選択順](https://github.com/suzuki-shunsuke/ghtkn/blob/main/docs/git-credential-helper.md#switching-github-apps-to-access-fork-repositories)

mise には独自変数の `GHTKN_GIT_APP_READ` / `GHTKN_GIT_APP_WRITE` を設定し、`GHTKN_GIT_APP` は設定しない。関数が選んだ App を実行時だけ `GHTKN_GIT_APP` に渡すため、shim による mise 環境の再適用と衝突しない。

`git()` / `gh()` を呼ぶたびに **両方の環境変数**を確認し、どちらかが未設定・空なら、ローカル操作を含むすべての git / gh 呼び出しを終了コード 1 で止める。`ghq()` は `get` / `clone` のときだけ同じ確認を行う。スクリプトの読み込み時には確認しない。

| 操作 | App / 挙動 |
|---|---|
| `git push` | write（`git -C <repo> push` なども対象） |
| その他の git 操作 | read |
| `gh repo create` / `gh pr create` / `gh release create` / `gh release delete` | write。子 Git にも同じ App を渡す |
| `gh auth login` / `gh auth token` | 拒否。認証には `ghtkn auth` を使い、トークンを表示しない |
| その他の gh 操作 | read。追加の書き込み操作が必要なら関数の分岐を追加する |
| `ghq get` / `ghq clone`（`--update` を含む） | read。`GH_TOKEN` と、子 Git の credential helper 用 App を渡す |
| その他の ghq 操作 | 環境変数の確認・App の選択をせず、そのまま実行 |

`gitw` / `ghw` と mise wrappers は定義しない。App は呼び出し元シェルの環境変数で選ぶので、`git -C` や `gh -R` で別 org を指定しても自動で切り替わらない。対象 org のディレクトリへ移動してから実行する。

### ghq の認証

ghq には認証が関わる経路が二つある。`ghq get repo-name` のように owner を省略した場合、owner の補完で GitHub API に問い合わせる際に、依存ライブラリが `GH_TOKEN` / `GITHUB_TOKEN` を参照する。[補完処理](https://github.com/Songmu/gitconfig/blob/v0.2.2/special.go) Git リポジトリの取得・更新は Git 本体が行い、HTTPS 認証には credential helper を使う。[ghq の仕様](https://github.com/x-motemen/ghq/blob/v1.10.1/README.adoc)

`ghq get` / `ghq clone` では `ghtkn exec` で read App のトークンを `GH_TOKEN` に渡す。同時に `GHTKN_GIT_APP_READ` を実行時の `GHTKN_GIT_APP` に渡し、子 Git の `ghtkn git-credential` にも同じ read App を選ばせる。トークンは子プロセスに渡し、親シェルには export しない。

取得先 org の `mise.toml` が有効なディレクトリから、HTTPS URL または `owner/repo` を指定する。取得先のパスから App を自動選択する処理はない。

```sh
cd ~/workspace/github.com/example-org
ghq get https://github.com/example-org/example-repo.git
# 取得済みのリポジトリを更新する場合
ghq get --update example-org/example-repo
```

`ghq get -p`、SSH URL、更新対象の SSH remote は SSH 認証になる。ghq が起動する Git はシェル関数 `git()` を通らないため、同関数の SSH 検査も働かない。ghtkn を使う取得・更新では HTTPS を指定し、既存 remote も HTTPS に変更する。`ghq list` / `ghq root` などは org の環境変数がなくても利用できる。

### SSH remote の個別変更

`git()` はすべての登録 remote の fetch / push URL を検査する。未使用の remote や明示的な push URL も含め、`git@github.com:…` またはホストが `github.com` の `ssh://…` が残っていれば、ローカル操作も止めて HTTPS への変更コマンドを表示する。clone などで標準 GitHub SSH URL を直接渡した場合も拒否する。SSH の Host 別名や他サービスは対象外で、自動読み替えは行わない。

remote を修正する際は、関数を迂回する `command git` を使う。

```sh
command git remote set-url origin https://github.com/example-org/example-repo.git
# 明示的な push URL がある場合
command git remote set-url --push origin https://github.com/example-org/example-repo.git
```

既存の URL 読み替え設定により保存 URL と実際の接続 URL が異なる場合は、表示された修正案内を使う。保存 URL の置換が必要な場合は `command git config --fixed-value --replace-all ...` を案内し、HTTPS が SSH に読み替えられている場合は `url.*.insteadOf` の修正を案内する。

`gh pr create` も子 Git の push に備えて同じ remote 検査を行う。その他の gh 操作には SSH 検査を追加しない。これらの関数が効くのは読み込み済みの Zsh からの呼び出しだけで、IDE や `command git` などの直接呼び出しには適用されない。`ghq()` が行うのは上記の App 選択であり、SSH 検査は行わない。

### 適用と読み取り確認

source の変更を `chezmoi diff ~/.gitconfig ~/.zsh/github-auth.zsh` で確認し、ユーザーが次を実行して新しい Zsh を起動する。org の mise 設定、App 認証、HTTPS remote を準備してから、対象リポジトリ内で読み取りを確認する。

```sh
chezmoi apply ~/.gitconfig ~/.zsh/github-auth.zsh
# 新しい Zsh で対象 org 配下のリポジトリへ移動してから実行
git ls-remote origin HEAD
gh repo view --json nameWithOwner
```

source 更新だけでは実環境には反映されない。エージェントは home への適用、App 認証、トークンの取得・表示、push / PR 作成、コミットを行わない。

## Private tool（任意）

private GitHub repo のリリースを mise の **github バックエンド**で導入する仕組み。`mise install` が private repo を認証するために `GITHUB_TOKEN` が要るので、`run_onchange_after_install-mise-tools.sh` が **1Password から op-vault 経由でトークンを取得**して `mise install` の直前に export する。public repo にシークレット・内部参照（対象 repo 名・バージョンも含む）を残さないため、op アカウント・シークレット参照・repo 名・バージョンはすべて chezmoi の `[data]` (上記 step 4) から注入する。

**opt-in**: `private_tool_repo` を設定したマシンでだけ有効（`hasKey` ゲート）。未設定のマシンでは `config.local.toml` 自体が展開されず (`.chezmoiignore` で制御)・トークン処理も走らないため、`chezmoi apply` は通常どおり成功する。`private_tool_repo` を設定していて `private_tool_version` を設定し忘れた場合は、chezmoi がキー未定義エラーで apply を止める（設定漏れに気付けるようにあえて fail-fast にしている）。

**なぜ `config.toml` と別ファイルなのか**: mise の lockfile は「宣言した config ファイル名の `.toml` → `.lock`」で決まり、`~/.config/mise/config.toml` の lock は `~/.config/mise/mise.lock`。この `mise.lock` は再現性のため dotfiles で追跡している (`dot_config/mise/private_mise.lock`) ので、private tool をここに書くと **repo 名とリリースアセット URL が public repo に載ってしまう**。そのため private tool は `~/.config/mise/config.local.toml` に隔離し、lock を `mise.local.lock`（追跡対象外）へ分離している。

- `conf.d/*.toml` は lockfile が親ディレクトリの `mise.lock` に**合流する**ため隔離手段にならない。
- `MISE_ENV` 方式は全プロジェクトディレクトリに波及するうえ、chezmoi のスクリプトは非対話 bash で走り `.zshenv` を読まないため apply 時にツールが入らない。

**バージョン更新**: `~/.config/chezmoi/chezmoi.toml` の `private_tool_version` を書き換えて `chezmoi apply` するだけ。dotfiles 側のコミットは不要（スクリプトのバージョン hash 行が変わるので `mise install` も再実行される）。`mise.local.lock` の更新もあわせて行うなら `mise lock -g`（追跡対象外なのでコミットは不要）。

導入するマシンで一度だけ用意しておくもの:

1. 1Password デスクトップアプリの **CLI 連携を有効化**し、`op-vault init` を実行する ([op-vault](https://github.com/sunakan/op-vault) は 1Password SDK 利用のため `op` CLI に依存しない。`op` 自体は Brewfile で別途入るが、この仕組みの前提ではない)。
2. private repo を読める **GitHub PAT を 1Password に保存**し、その `op://<Vault>/<Item>/<field>` 参照を `private_tool_token_ref` に設定する。
3. `private_tool_repo` / `op_account` / `private_tool_token_ref` を `~/.config/chezmoi/chezmoi.toml` の `[data]` に設定する（3つセット）。

> トークンを解決できない (1Password ロック・変数未設定等) 場合、スクリプトは **中断**する (silent skip しない)。導入対象マシンで一時的に他ツールだけ入れたいときは 1Password を解錠してから再 apply すること。

## mise lockfile の更新

`~/.config/mise/mise.lock`（全ツールの version / URL / checksum を複数プラットフォーム分固定した lockfile）は `dot_config/mise/private_mise.lock` として追跡している。**生成物なので手で編集せず**、ツールを追加・バージョン変更したら `mise lock -g` → `cp` で source へ同期してコミットする（`dot_agents/dot_skill-lock.json` と同じ「実体を `cp` で追跡」パターン）。`mise install` だけでは現在の platform 分しか lock されず、削除済みツールのエントリも残るため `mise lock -g` を挟むのが必須。

**手順・検証コマンド・注意点は [`.agents/skills/mise-lock-update/SKILL.md`](.agents/skills/mise-lock-update/SKILL.md) に集約している**（Codex では `$mise-lock-update`、Claude Code では `/mise-lock-update` で起動できる。`.claude/skills` は `.agents/skills` への symlink）。

> **`cp` した直後の `chezmoi diff` は空にならない。** `install-mise-tools.sh` が `new file mode 100755` として全文表示される。これはファイル差分ではなく「apply したらこのスクリプトが走る」という予告で、lockfile の中身が変わるとスクリプトに埋め込まれた `# lockfile hash:` 行が変わり run_onchange の再実行対象になるため。**もう一度 `chezmoi apply` すれば `mise install` が冪等に走って diff が収束する。** 見るべきは「diff が空か」ではなく「`.config/mise/mise.lock` のファイル差分が出ていないか」。

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

# Claude Code の blocklist / config を source 側に同期 (drift したとき)
# settings.json は modify_ が、plugins の marketplaces/installed は run_onchange が
# 面倒を見るので re-add 不要。手動編集したときだけ blocklist/config を取り込む。
chezmoi re-add ~/.claude/plugins/blocklist.json ~/.claude/plugins/config.json

# brew drift: インストール済みだが Brewfile にない formula を追加
brewfile-add <formula>
brewfile-add --cask <cask>

# drift チェックを手動で強制実行（1日1回キャッシュを無視）
# ※ source して関数として呼ぶ必要がある（スクリプト直接実行では --force が届かない）
source ~/.zsh/brew_drift_check.zsh && brew-drift       # Brewfile との差分を確認
source ~/.zsh/drift_check.zsh && dotfiles-drift        # git・chezmoi の差分を確認
```

> **Note (Claude Code 設定の drift):** `settings.json` の `feedbackSurveyState` / `enabledPlugins` / `extraKnownMarketplaces`（Claude Code が実行時に書き換えるキー）は `modify_settings.json.tmpl` が実ファイルの値を保持するため diff は出ない。`plugins/known_marketplaces.json` / `installed_plugins.json` は `.chezmoiignore` 済みで追跡しない。→ 以前のようにタイムスタンプや git SHA で `chezmoi diff` が出続けることはない。
