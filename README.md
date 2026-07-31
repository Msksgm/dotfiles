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
| `dot_zsh/herdr.zsh` | `~/.zsh/herdr.zsh`（herdr 用のシェル設定。自分の pane ID を herdr にカスタムトークンとして報告する `_herdr_report_pane_id` を定義する。`~/.zsh/*.zsh` の source は `mise activate` より前で herdr が PATH に無いため、**定義だけを置き呼び出しは `dot_zshrc` の mise activate 直後**に置いている） |
| `dot_tmux.conf` | `~/.tmux.conf` |
| `executable_dot_tmux-rename-session` | `~/.tmux-rename-session` |
| `dot_gitconfig.tmpl` | `~/.gitconfig` |
| `dot_ideavimrc` | `~/.ideavimrc` |
| `dot_crit.config.json` | `~/.crit.config.json`（crit のグローバル設定。`plan_approve_mode` で plan 承認後の Claude Code permission mode を指定する。プロジェクト側 `.crit.config.json` からは上書き不可） |
| `dot_config/nvim/` | `~/.config/nvim/` |
| `dot_config/karabiner/karabiner.json` | `~/.config/karabiner/karabiner.json` |
| `dot_config/mise/config.toml.tmpl` | `~/.config/mise/config.toml`（言語ランタイム + aqua バックエンドの主要 CLI ツール群。aqua 未登録のツールは github バックエンド。**private tool はここに書かない** — lockfile `mise.lock` を追跡しているため、下記 `config.local.toml` に隔離する） |
| `dot_config/mise/private_config.local.toml.tmpl` | `~/.config/mise/config.local.toml`（private tool 専用の machine-local config。mode 0600。`private_tool_repo` を設定したマシンでのみ展開され、lockfile は `mise.local.lock` に分離されて追跡されない） |
| `dot_config/mise/private_mise.lock` | `~/.config/mise/mise.lock`（mise の lockfile。全ツールの version / URL / checksum を 7 プラットフォーム分固定して再現性を担保する。mode 0600。**生成物なので手で編集せず** `mise lock -g` → `cp` で同期する。手順は下記 "mise lockfile の更新" 参照） |
| `dot_config/helm/repositories.yaml` | `~/.config/helm/repositories.yaml` |
| `dot_config/cage/presets.yml` | `~/.config/cage/presets.yml` |
| `dot_config/herdr/config.toml` | `~/.config/herdr/config.toml`（キーバインドを `dot_tmux.conf` に合わせた herdr 設定。prefix=`C-j`、分割 `\|`/`-`、ペイン移動 h/j/k/l、タブ移動 `C-h`/`C-l`、デタッチ `prefix+d`、workspace 作成 `prefix+Shift+C`、workspace リネーム `prefix+Space`、pane を新 tab に切り出し `prefix+!`（tmux の break-pane 相当。組み込みアクションが無いため `herdr pane move --new-tab` を shell command で呼ぶ）。加えて `[ui.sidebar.agents]` で左サイドバーの agent 行に pane ID (`wG:pB`) を表示する。この `$pane_id` はカスタムトークンで、**値の供給は `dot_zsh/herdr.zsh` に依存する** — 片方だけ消すと ID が空欄になる） |
| `dot_config/herdr/executable_rename-workspace.sh` | `~/.config/herdr/rename-workspace.sh`（実行ビット付き。focused workspace を git リポジトリ名にリネームする。tmux の `~/.tmux-rename-session` の herdr 版で、config.toml の `[[keys.command]]` から `prefix+Space` で呼ぶ） |
| `dot_claude/modify_settings.json.tmpl` | `~/.claude/settings.json`（chezmoi `modify_` スクリプト。自分が管理するキー（env/permissions/model/hooks/deny 等）だけ強制し、Claude Code が実行時に書き換えるキー（`enabledPlugins`/`extraKnownMarketplaces`/`feedbackSurveyState`）は実ファイルから保持してドリフトを防ぐ。herdr フックパスは `{{ .chezmoi.homeDir }}` で展開） |
| `dot_claude/hooks/executable_herdr-agent-state.sh` | `~/.claude/hooks/herdr-agent-state.sh`（実行ビット付き。settings.json の SessionStart フックが呼ぶ herdr の Claude 連携スクリプト。**herdr が自動管理し integration 更新時に上書きするため source はスナップショット**。更新時は再 `cp` で同期する） |
| `dot_claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `dot_claude/agents/*.md` | `~/.claude/agents/*.md` (user-level subagent) |
| `dot_claude/rules/*.md` | `~/.claude/rules/*.md` (CLAUDE.md から `@`-import するコーディング規約) |
| `dot_claude/rules/golang/*.md` | `~/.claude/rules/golang/*.md` (Go 固有ルール。`@`-import せず参照用) |
| `dot_claude/rules/kotlin/*.md` | `~/.claude/rules/kotlin/*.md` (Kotlin 固有ルール。`@`-import せず参照用) |
| `dot_claude/plugins/config.json` | `~/.claude/plugins/config.json` |
| `dot_claude/plugins/private_blocklist.json` | `~/.claude/plugins/blocklist.json` |
| `dot_claude/symlink_skills` | `~/.claude/skills` → `~/.agents/skills` (symlink) |
| `dot_agents/dot_skill-lock.json` | `~/.agents/.skill-lock.json` |
| `dot_agents/skills-local/review-io-impact/SKILL.md` | `~/.agents/skills-local/review-io-impact/SKILL.md`（インストーラ経由で `~/.agents/skills/review-io-impact/SKILL.md` にも展開） |
| `dot_agents/skills-local/svg-diagram/**` | `~/.agents/skills-local/svg-diagram/`（SKILL.md + `components/` `examples/` の HTML テンプレート。インストーラ経由で `~/.agents/skills/svg-diagram/` にも展開） |

> **Note (agent skills):** skill の導入チャネルは2種類ある。① **GitHub lock チャネル**: [`skills`](https://github.com/vercel-labs/skills) CLI で導入する skill の正本は `~/.agents/skills/` (store)。`~/.claude/skills` はそこへの symlink で、Claude Code から同じ skill を共有する。`~/.agents/.skill-lock.json` (どの GitHub ソースから入れたかの記録) を管理対象にしており、これが変わると `run_onchange_after_install-skills.sh` が `chezmoi apply` 時に各 skill を `skills add` で再取得する (Brewfile と同じ仕組み)。skill を追加/削除したら `cp ~/.agents/.skill-lock.json dot_agents/dot_skill-lock.json` で lock を source へ同期してコミットする。② **自作 skill チャネル**: `dot_agents/skills-local/<name>/` に `SKILL.md`（とサポートファイル）を置き、`run_onchange_after_install-local-skills.sh` が `chezmoi apply` 時に `~/.agents/skills/<name>/` へコピーする。GitHub チャネルは lock 外のフォルダを削除しないため両チャネルは共存できる。store 本体 (`~/.agents/skills/**`) は再生成可能なので `.chezmoiignore` で除外（自作スキルの source は `dot_agents/skills-local/` に残る）。自作 skill を**削除**するときは source から消すだけでは足りず、`run_onchange_after_install-local-skills.sh.tmpl` の `REMOVED_SKILLS` 配列（store 側の実体を除去）と `.chezmoiremove`（`~/.agents/skills-local/` 側の残骸を除去。残すと毎回再インストールされる）の2箇所に追記する。

> **Note (Claude Code plugins):** プラグインの導入は `run_onchange_after_install-claude-plugins.sh.tmpl` の **inline manifest**（`MARKETPLACES` / `PLUGINS` 配列）が唯一の source of truth。`chezmoi apply` 時にこのスクリプトが `claude plugin marketplace add` + `claude plugin install` を冪等に流し、marketplace の clone と cache 本体を再生成する（skills store と同じ「ignore して run_onchange で再生成」方式）。Claude Code が実行時に所有する `known_marketplaces.json` / `installed_plugins.json` は `.chezmoiignore` 済みで**追跡しない**（タイムスタンプ等のドリフトが出ない）。有効化状態 `enabledPlugins` は `modify_settings.json.tmpl` が新規マシン用に seed し、以降は Claude Code の値を保持する。現在は公式 LSP (`gopls-lsp` / `rust-analyzer-lsp` @ `claude-plugins-official`) と [`ecc`](https://github.com/affaan-m/ECC) (`ecc@ecc`)、[`crit`](https://github.com/tomasz-tomczyk/crit) (`crit@crit`) を管理 (ecc は **Claude Code CLI ≥ v2.1.0** 必須)。プラグインを増減するときは manifest 配列を編集するだけ（JSON への手動反映や `chezmoi re-add` は不要）。

> **Note (二重チャネル管理ツール):** crit / herdr は CLI（mise）と Claude 連携（plugin / skill / hook）の**複数チャネルで同じツールを管理**している。CLI のバージョンだけ上げると連携側が古いままズレるため、更新時は両方を揃えること。対応表と更新手順は `CLAUDE.md` の「二重チャネル管理ツール（CLI + Claude 連携）」を参照。

## Excluded from management

以下は認証トークンや機密情報を含むため管理対象外。

| パス | 理由 |
|---|---|
| `~/.config/chezmoi/` | chezmoi 設定ファイル (`sourceDir` / `[data]` の手動変数を含む) |
| `~/.config/gh/` | GitHub CLI 認証トークン |
| `~/.config/github-copilot/` | GitHub Copilot 認証トークン |
| `~/.config/configstore/` | 各種ツールの認証情報 |
| `~/.config/nvim/lazyvim.json` | LazyVim が自動更新する既読状態ファイル |
| `~/.config/mise/mise.local.lock` | `config.local.toml`（private tool）の lockfile。private repo 名とリリースアセット URL を含むため public repo に置けない。`mise lock -g` を実行すると（`mise.lock` と一緒に）各マシンで自動生成される |
| `~/.agents/skills/` | skills CLI が GitHub から取得する store。lock から再生成可能 (`run_onchange_after_install-skills.sh`) |
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

## Private tool（任意）

private GitHub repo のリリースを mise の **github バックエンド**で導入する仕組み。`mise install` が private repo を認証するために `GITHUB_TOKEN` が要るので、`run_onchange_after_install-mise-tools.sh` が **1Password から op-vault 経由でトークンを取得**して `mise install` の直前に export する。public repo にシークレット・内部参照（対象 repo 名・バージョンも含む）を残さないため、op アカウント・シークレット参照・repo 名・バージョンはすべて chezmoi の `[data]` (上記 step 4) から注入する。

**opt-in**: `private_tool_repo` を設定したマシンでだけ有効（`hasKey` ゲート）。未設定のマシンでは `config.local.toml` 自体が展開されず (`.chezmoiignore` で制御)・トークン処理も走らないため、`chezmoi apply` は通常どおり成功する。`private_tool_repo` を設定していて `private_tool_version` を設定し忘れた場合は、chezmoi がキー未定義エラーで apply を止める（設定漏れに気付けるようにあえて fail-fast にしている）。

**なぜ `config.toml` と別ファイルなのか**: mise の lockfile は「宣言した config ファイル名の `.toml` → `.lock`」で決まり、`~/.config/mise/config.toml` の lock は `~/.config/mise/mise.lock`。この `mise.lock` は再現性のため dotfiles で追跡している (`dot_config/mise/private_mise.lock`) ので、private tool をここに書くと **repo 名とリリースアセット URL が public repo に載ってしまう**。そのため private tool は `~/.config/mise/config.local.toml` に隔離し、lock を `mise.local.lock`（追跡対象外）へ分離している。

- `conf.d/*.toml` は lockfile が親ディレクトリの `mise.lock` に**合流する**ため隔離手段にならない。
- `MISE_ENV` 方式は全プロジェクトディレクトリに波及するうえ、chezmoi のスクリプトは非対話 bash で走り `.zshenv` を読まないため apply 時にツールが入らない。

**バージョン更新**: `~/.config/chezmoi/chezmoi.toml` の `private_tool_version` を書き換えて `chezmoi apply` するだけ。dotfiles 側のコミットは不要（スクリプトのバージョン hash 行が変わるので `mise install` も再実行される）。`mise.local.lock` の更新もあわせて行うなら `mise lock -g`（追跡対象外なのでコミットは不要）。

導入するマシンで一度だけ用意しておくもの:

1. 1Password デスクトップアプリの **CLI 連携を有効化**し、`op-vault init` を実行する ([op-vault](https://github.com/sunakan/op-vault) は 1Password SDK 利用のため `op` CLI は不要)。
2. private repo を読める **GitHub PAT を 1Password に保存**し、その `op://<Vault>/<Item>/<field>` 参照を `private_tool_token_ref` に設定する。
3. `private_tool_repo` / `op_account` / `private_tool_token_ref` を `~/.config/chezmoi/chezmoi.toml` の `[data]` に設定する（3つセット）。

> トークンを解決できない (1Password ロック・変数未設定等) 場合、スクリプトは **中断**する (silent skip しない)。導入対象マシンで一時的に他ツールだけ入れたいときは 1Password を解錠してから再 apply すること。

## mise lockfile の更新

`~/.config/mise/mise.lock`（全ツールの version / URL / checksum を 7 プラットフォーム分固定した lockfile）は `dot_config/mise/private_mise.lock` として追跡している。**生成物なので手で編集せず**、ツールを追加・バージョン変更したら次の手順で source へ同期してコミットする（`dot_agents/dot_skill-lock.json` と同じ「実体を `cp` で追跡」パターン）。

```sh
# 1. dot_config/mise/config.toml.tmpl の [tools] を編集したあと
chezmoi apply -v    # run_onchange が mise install を実行する

# 2. 全プラットフォーム分の URL/checksum を再解決する
#    ※ mise install だけでは「現在の platform 分しか lock されず、削除済みツールも残る」
#    ※ GITHUB_TOKEN は必須。未認証だと 60 req/h で即座にレート制限に当たり、
#      403 で取りこぼした platform エントリが歯抜けのまま lock に書かれる
export GITHUB_TOKEN="$(gh auth token)"
mise lock -g

#    取りこぼしが無いか確認する（7 未満は上流が全 platform を配布していない場合もある）
awk '/^\[\[tools\./{n++; c[n]=0} /^\[tools\..*platforms\./{c[n]++} \
  END{f=0; for(i=1;i<=n;i++) if(c[i]>=7) f++; print f" / "n" tools with 7 platforms"}' ~/.config/mise/mise.lock

# 3. private な参照が混ざっていないか確認（owner が全部 public であること）
grep -o 'github\.com/[^/]*/[^/"]*' ~/.config/mise/mise.lock | sort -u

# 4. source へ同期 → diff が空になることを確認 → コミット
cp ~/.config/mise/mise.lock "$(chezmoi source-path)/dot_config/mise/private_mise.lock"
chezmoi diff
```

> `uv` の `"latest"` は lockfile があると固定される（自動更新されなくなる）。上げたいときは `mise lock -g --bump`（config は書き換えない）を挟んでから手順 4 へ。
>
> `"latest"` は lockfile 追跡下では自動更新の利点が消える一方、resolve が意図しない古いバージョンを掴むと `mise install` が失敗し続ける（`android-sdk` が `1.0` に固定されて壊れた実例あり）。新規ツールは原則 `"latest"` を使わず明示ピンにすること。

**`mise lock` の注意点:**

- **既に lockfile にある platform しか更新しない。** 新しく platform を増やすには `-p` で明示する必要がある（`mise lock -g -p linux-arm64,linux-arm64-musl,linux-x64,linux-x64-musl,macos-arm64,macos-x64,windows-x64`）。上流が配布していない platform は書かれず、以後その集合が「既存」になるので数は自然に落ち着く。7 未満のツールがあっても異常ではない（例: `github:sunakan/op-vault` は darwin_arm64 のみ配布なので 1）。
- GitHub の build attestation を公開しているツール（uv / gh / jq / yq / pinact / ghtkn / op-vault 等）は、provenance 記録のため **lock のたびにアーティファクト実体をダウンロードする**（キャッシュされない）。実行が遅いのはこれが理由で、異常ではない。

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
