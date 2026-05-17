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

## run_once スクリプト

`run_once_setup.sh` は `chezmoi apply` 時に**一度だけ**実行される（chezmoi の state DB に実行済みとして記録）。内容変更時は再実行される。現在は `rustup-init` の初期化のみ。

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

`README.md` / `Brewfile` / `_archive/` / `.gitignore` / `CLAUDE.md` は chezmoi の管理外（home に展開されない）。新たに管理外ファイルを追加する場合はこのファイルに記載する。

## 注意事項

- **このリポジトリは public**。機密情報（token、email 等）は直接書かず `{{ .variable }}` でテンプレート化すること
- ハードコードされたパスは `$HOME`（シェルスクリプト内）または `{{ .chezmoi.homeDir }}`（テンプレート内）を使用すること
- `dot_gitconfig.tmpl` の `{{ .github_username }}` / `{{ .github_email }}` は `~/.config/chezmoi/chezmoi.toml` の `[data] github_username` / `[data] github_email` で注入する。新規マシンでは apply 前にこの設定が必要
