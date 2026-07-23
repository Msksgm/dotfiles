# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

chezmoi による macOS dotfiles リポジトリ。source dir は `~/workspace/github.com/Msksgm/dotfiles`（ghq 管理下）。`~/.config/chezmoi/chezmoi.toml` はローカル専用で**このリポジトリに含まれない**。

## chezmoi 命名規則

| source ファイル名 | home 側の展開先 |
|---|---|
| `dot_foo` | `~/.foo` |
| `dot_config/bar/baz` | `~/.config/bar/baz` |
| `executable_dot_foo` | `~/.foo` (実行ビット付き) |
| `foo.tmpl` | `~/foo` (Go template として評価) |

## テンプレート変数

`dot_gitconfig.tmpl` で使用中:
- `{{ .github_username }}` — `~/.config/chezmoi/chezmoi.toml` の `[data] github_username` から注入（GitHub アカウント名 = git の user.name）
- `{{ .github_email }}` — `~/.config/chezmoi/chezmoi.toml` の `[data] github_email` から注入（GitHub アカウントに紐づく email = git の user.email）
- `{{ .chezmoi.homeDir }}` — chezmoi が自動提供するホームディレクトリパス

`dot_config/mise/config.toml.tmpl` / `run_onchange_after_install-mise-tools.sh.tmpl` で使用中（private GitHub repo のツール導入用。任意。public repo に内部参照＝対象 repo 名を残さないためテンプレート化）:
- `{{ .private_tool_repo }}` — private tool の `owner/repo`（プレースホルダ `<owner>/<repo>`）。github バックエンドの tool spec に使用。`hasKey` ゲートで設定マシンのみ導入
- `{{ .op_account }}` — op-vault の `OP_ACCOUNT`（1Password アカウント識別子）
- `{{ .private_tool_token_ref }}` — private repo を読める GitHub PAT の `op://<Vault>/<Item>/<field>` 参照

`Brewfile.tmpl` で使用中（マシン依存の container runtime cask を出し分ける。任意。規約に応じて使い分ける）:
- `install_orbstack` — `hasKey` ゲート。設定したマシンでのみ `cask "orbstack"` を install
- `install_docker_desktop` — `hasKey` ゲート。設定したマシンでのみ `cask "docker-desktop"` を install
  - 値は `true` を推奨するが `hasKey` はキーの存在だけを見るため何でもよい。両方設定すれば両方入る

新たにテンプレートを使う場合はファイル名に `.tmpl` を付けて同じ変数を参照できる。手動変数を増やしたら README の "Template variables" 表と New machine setup step 4 も更新すること。

## run_once / run_onchange スクリプト

- `run_once_setup.sh` — `chezmoi apply` 時に**一度だけ**実行される（chezmoi の state DB に実行済みとして記録）。内容変更時は再実行される。現在は `rustup-init` の初期化のみ。
- `run_onchange_install-packages.sh.tmpl` — `chezmoi apply` 時、**スクリプト内容が変わるたび**に実行される。先頭コメントに `{{ include "Brewfile.tmpl" | sha256sum }}` で `Brewfile.tmpl` のハッシュを埋め込んでいるため、**`Brewfile.tmpl` を編集すると次の apply で `brew bundle` が自動実行**される。`.tmpl` なので Go template として評価される。`Brewfile.tmpl` はマシン依存の cask（orbstack / docker-desktop）を `hasKey` ゲートで囲むため、`brew bundle` の直前に `chezmoi execute-template` でレンダリングした一時ファイルを bundle する（`.chezmoiignore` 済みで home には展開しない）。**注意**: ハッシュは raw template のため、`Brewfile.tmpl` を編集せず chezmoi.toml の `install_*` キーだけ変更した場合は自動再実行されない。その場合は手動で `brew bundle` するか、apply 時に該当スクリプトを再走させること。
- `run_onchange_after_install-skills.sh.tmpl` — 同じ仕組みで、`{{ include "dot_agents/dot_skill-lock.json" | sha256sum }}` のハッシュ埋め込みにより **`dot_agents/dot_skill-lock.json` が変わると次の apply で skill が再インストール**される。lock の各 skill を `skills add <source> -g -a claude-code -y` で取得し、正本 store `~/.agents/skills/` を再生成する。`after_` プレフィックスは `~/.claude/skills` symlink (`dot_claude/symlink_skills`) が作られた**後**にスクリプトを走らせるため。node/npx は mise 経由なので、冒頭で `brew shellenv` + mise shims を PATH に通し、未検出時は apply を止めずスキップする。
- `run_onchange_after_install-local-skills.sh.tmpl` — **自作 skill の第3チャネル**。`dot_agents/skills-local/*/` に置いたスキルを `~/.agents/skills/` へ `cp -R` でコピーする。先頭コメントに各スキルファイルの sha256sum を埋め込んでいるため、**自作スキルのファイルを編集すると次の apply でコピーが再実行**される。GitHub lock チャネル（`run_onchange_after_install-skills.sh.tmpl`）は lock 外のフォルダを削除しないため、両チャネルのスキルは `~/.agents/skills/` 内で別フォルダとして共存できる。自作スキルを追加・編集したら、対応する `SKILL.md` / サポートファイルを `dot_agents/skills-local/<name>/` に置いてコミットすること。
- `run_onchange_after_install-mise-tools.sh.tmpl` — 同じ仕組みで、`{{ include "dot_config/mise/config.toml.tmpl" | sha256sum }}` のハッシュ埋め込みにより **`dot_config/mise/config.toml.tmpl` が変わると次の apply で `mise install` が走る**。`after_` プレフィックスで `run_onchange_install-packages.sh.tmpl`（brew が mise 本体を入れる）の**後**に実行し、mise バイナリの存在を保証する。aqua バックエンドへ移行した CLI ツール群はここでインストールされる。mise 未検出時は apply を止めずスキップ。private GitHub repo のツールを github バックエンドで入れるため、`mise install` の直前に op-vault (`mise exec "github:sunakan/op-vault"`) で 1Password から `GITHUB_TOKEN` を解決・export する。この処理は `{{ if hasKey . "private_tool_repo" }}` ゲートで囲まれ、変数を設定したマシンでだけ有効（未設定マシンでは private tool 行が config にも出ず、apply は通常成功）。トークンを解決できなければ apply を**中断**する（他ツールも止まるが silent skip はしない）。

依存パッケージ（`powerlevel10k` 等）は必ず `Brewfile.tmpl` に追加すること。`dot_zshrc` から参照するだけで Brewfile に無いと、新規マシンで未インストールになり壊れる。`Brewfile.tmpl` は Go template として評価されるので、マシンによって入れ分けたい cask（container runtime 等）は `{{ if hasKey . "install_xxx" }}` ゲートで囲み、chezmoi.toml の `[data]` にキーを設定したマシンでだけ install されるようにすること（orbstack / docker-desktop が例）。主要な single-binary CLI ツール群は Homebrew から aqua バックエンドへ移行済み。新規 CLI ツールは原則 Brewfile ではなく `dot_config/mise/config.toml.tmpl` の `[tools]` に `"aqua:<owner>/<repo>" = "<version>"` 形式で追加すること。`brew info --json=v2 <formula>` で上流 owner/repo を確認し、`mise ls-remote aqua:<id>` でバージョン実在を確認してから追記する。GNU/system 系・bootstrap ツール（chezmoi/mise）・等価性が曖昧なもの（tmux/aws-vault/coreutils）は引き続き Homebrew が担う。**private repo のツールは例外**として、aqua レジストリに載らないため github バックエンド（`"github:<owner>/<repo>" = "<version>"`）で入れ、認証用 `GITHUB_TOKEN` を op-vault 経由で解決する。対象 repo 名・op 参照はテンプレート変数（`private_tool_repo` 等）で注入し public repo に残さず、`hasKey` ゲートで設定マシンのみ opt-in にする（上記の mise-tools スクリプトとテンプレート変数を参照）。

agent skill を追加/削除したら、`~/.agents/.skill-lock.json` を `dot_agents/dot_skill-lock.json` へ同期 (`cp`) してコミットすること。lock が source 側に反映されないと、新規マシンで skill が復元されない。

## よく使うコマンド

```sh
chezmoi diff          # home との差分確認（apply 前に必ず実行）
chezmoi apply -v      # source を home に適用
chezmoi managed       # 管理対象ファイル一覧
chezmoi update        # remote pull + apply
```

> **`chezmoi diff` / `apply` / `update` などの home への適用操作はユーザーが実行する。** Claude は `dot_*` 等の source ファイルの編集までを担当し、apply の実行やコミット可否の判断はユーザーに委ねること。

## ファイルを新たに管理対象に追加する手順

```sh
# 1. home から source へコピー（ファイル単位で、ディレクトリごと cp -R しない）
cp ~/.config/foo/bar.conf dot_config/foo/bar.conf

# 2. 差分が空であること（内容が一致していれば OK）を確認
chezmoi diff

# 3. コミット前に機密情報がないか確認
grep -iE '(token|secret|password|api.?key)' dot_config/foo/bar.conf

# 4. README.md の "Managed files" テーブルに追記してからコミット
```

## .chezmoiignore

**パスは target 基準** (`dot_` プレフィックスを付けず、home からの相対パス)。例: source の `dot_config/nvim/lazyvim.json` を除外したい場合は `.config/nvim/lazyvim.json` と書く。

除外対象に追加すべき典型ケース:
- **リポジトリのメタファイル** (`README.md` / `CLAUDE.md` / `.gitignore` 等) — home に展開する意味がないもの
- **ツールが自動更新するファイル** (LazyVim の `lazyvim.json` 等) — apply のたびに diff が出続けて煩わしく、source 側の値で上書きされると挙動が壊れる
- **`_archive/`** — 退避用ディレクトリ。`_archive/**` も併記する
- **機密情報を含むファイル** — `~/.config/gh/` や `~/.config/chezmoi/` 等の認証トークン類

追加後は **README.md の "Excluded from management" テーブルに理由付きで追記** すること。"Managed files" 配下のディレクトリ (例: `dot_config/nvim/`) から個別ファイルを除外した場合も同様に Excluded 側に明記する (テーブルを見ただけで除外理由が分かるようにするため)。

source 側にファイルが残っていると死蔵されるので、`.chezmoiignore` への追記と同時に `rm dot_config/...` で source ファイルも削除する。

## Claude Code の user-level 設定 (`dot_claude/`)

- `dot_claude/CLAUDE.md` (→ `~/.claude/CLAUDE.md`) — 全プロジェクト共通の指示。`@rules/*.md` で `~/.claude/rules/` 配下を `@`-import する。
- `dot_claude/agents/*.md` (→ `~/.claude/agents/*.md`) — user-level subagent (architect / code-reviewer / pm-reviewer / qa-reviewer)。frontmatter に `name` / `description` / `tools` / `model` を持つ通常の Markdown。skills のような symlink/lock 機構の対象外で、ファイルを置くだけで反映される。
- `dot_claude/rules/*.md` (→ `~/.claude/rules/*.md`) — コーディング規約 docs。`dot_claude/CLAUDE.md` から参照される。

## 注意事項

- **このリポジトリは public**。機密情報（token、email 等）は直接書かず `{{ .variable }}` でテンプレート化すること
- ハードコードされたパスは `$HOME`（シェルスクリプト内）または `{{ .chezmoi.homeDir }}`（テンプレート内）を使用すること
- `dot_gitconfig.tmpl` の `{{ .github_username }}` / `{{ .github_email }}` は `~/.config/chezmoi/chezmoi.toml` の `[data] github_username` / `[data] github_email` で注入する。新規マシンでは apply 前にこの設定が必要
