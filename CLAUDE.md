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

新たにテンプレートを使う場合はファイル名に `.tmpl` を付けて同じ変数を参照できる。

## run_once / run_onchange スクリプト

- `run_once_setup.sh` — `chezmoi apply` 時に**一度だけ**実行される（chezmoi の state DB に実行済みとして記録）。内容変更時は再実行される。現在は `rustup-init` の初期化のみ。
- `run_onchange_install-packages.sh.tmpl` — `chezmoi apply` 時、**スクリプト内容が変わるたび**に実行される。先頭コメントに `{{ include "Brewfile" | sha256sum }}` で Brewfile のハッシュを埋め込んでいるため、**Brewfile を編集すると次の apply で `brew bundle` が自動実行**される。`.tmpl` なので Go template として評価される。
- `run_onchange_after_install-skills.sh.tmpl` — 同じ仕組みで、`{{ include "dot_agents/dot_skill-lock.json" | sha256sum }}` のハッシュ埋め込みにより **`dot_agents/dot_skill-lock.json` が変わると次の apply で skill が再インストール**される。lock の各 skill を `skills add <source> -g -a claude-code -y` で取得し、正本 store `~/.agents/skills/` を再生成する。`after_` プレフィックスは `~/.claude/skills` symlink (`dot_claude/symlink_skills`) が作られた**後**にスクリプトを走らせるため。node/npx は mise 経由なので、冒頭で `brew shellenv` + mise shims を PATH に通し、未検出時は apply を止めずスキップする。

依存パッケージ（`powerlevel10k` 等）は必ず Brewfile に追加すること。`dot_zshrc` から参照するだけで Brewfile に無いと、新規マシンで未インストールになり壊れる。

agent skill を追加/削除したら、`~/.agents/.skill-lock.json` を `dot_agents/dot_skill-lock.json` へ同期 (`cp`) してコミットすること。lock が source 側に反映されないと、新規マシンで skill が復元されない。

## よく使うコマンド

```sh
chezmoi diff          # home との差分確認（apply 前に必ず実行）
chezmoi apply -v      # source を home に適用
chezmoi managed       # 管理対象ファイル一覧
chezmoi update        # remote pull + apply
```

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

## 注意事項

- **このリポジトリは public**。機密情報（token、email 等）は直接書かず `{{ .variable }}` でテンプレート化すること
- ハードコードされたパスは `$HOME`（シェルスクリプト内）または `{{ .chezmoi.homeDir }}`（テンプレート内）を使用すること
- `dot_gitconfig.tmpl` の `{{ .github_username }}` / `{{ .github_email }}` は `~/.config/chezmoi/chezmoi.toml` の `[data] github_username` / `[data] github_email` で注入する。新規マシンでは apply 前にこの設定が必要
