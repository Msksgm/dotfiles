---
name: codex-version-update
description: >-
  この dotfiles リポジトリで mise/aqua 管理の Codex CLI を指定版または最新の安定版へ更新し、公式 changelog の確認、config の version pin 編集、mise lock の再生成・同期、導入済みバージョンの検証まで進める。「Codex を更新して」「Codex CLI を最新版に」「Codex のバージョンを上げて」等の依頼で使う。API のモデル変更、Codex の設定変更、他リポジトリでの Codex 導入には使わない。
---

# Codex version update

`dot_config/mise/config.toml.tmpl` と `dot_config/mise/private_mise.lock` の Codex バージョンを一致させ、ユーザーによる apply 後に `codex --version` まで確認する。

## 管理元と境界

1. 最初に `chezmoi source-path ~/.config/mise/config.toml` を実行し、この dotfiles リポジトリの `dot_config/mise/config.toml.tmpl` が source であることを確認する。`chezmoi source-path` で取得した source root の `AGENTS.md` を読み、適用の共通ルールに従う。インストール先や作業ディレクトリからの相対パスで参照先を推測しない。
2. Codex CLI は `[tools]` の `"aqua:openai/codex"` で管理する。npm、Homebrew、個別 installer、`mise use -g` で別経路を作らない。
3. 未コミットの変更を確認して保持する。バージョン更新だけの依頼では `dot_codex/modify_private_config.toml` などの実行時設定を変更しない。
4. lockfile は生成物である。通常のバージョン更新では `dot_config/mise/private_mise.lock` の version、URL、checksum を手で書き換えない。

## 対象バージョンを決める

- 現在値は `rg -n '^"aqua:openai/codex" = ' dot_config/mise/config.toml.tmpl` で確認する。
- ユーザーがバージョンを指定した場合はそれを維持する。`rust-v0.x.y` または `v0.x.y` の既知 prefix は config 用の `0.x.y` に正規化し、そのことを伝える。
- 指定がなければ `mise latest aqua:openai/codex` で最新の安定版候補を取得する。prerelease はユーザーが明示した場合だけ採用する。
- 候補は [公式 Codex changelog](https://developers.openai.com/codex/changelog) の Codex CLI エントリと、`gh release view "rust-v<version>" -R openai/codex --json tagName,isDraft,isPrerelease,publishedAt,url` で照合する。draft、意図しない prerelease、対応する公式 release がない版は採用しない。
- 現在版から対象版までの changelog を確認し、破壊的変更、config schema の変更、廃止コマンド、配布方法の変更を要約する。version pin 以外の対応が必要でも、依頼範囲を超える変更は無断で加えずユーザーへ確認する。
- 現在値と対象値が同じならファイルを変更せず、既に最新である根拠を報告して終了する。

## Source を編集する

`dot_config/mise/config.toml.tmpl` の `"aqua:openai/codex"` の値だけを対象版へ変更する。backend 名、コメント、並び、無関係なツールは保持する。

編集後に次を確認する。

- Codex の tool 定義が1件だけで、対象バージョンに pin されている。
- `git diff --check` が成功する。
- diff に意図した1行以外の新規変更がない。ただし作業開始前からあったユーザー変更は除外する。

## Lock を更新する

config の編集後は、上で特定した source root の `.agents/skills/mise-lock-update/SKILL.md` を必ず読む。適用の共通ルールは同じ source root の `AGENTS.md`、lock 更新固有の実行分担・手順・再適用のタイミングは `mise-lock-update` に従う。ユーザーに引き渡す操作はその手順から提示する。

ユーザーが同期を完了したら、agent が source を読み取り専用で検証する。

- `[[tools."aqua:openai/codex"]]` が1ブロックだけ存在する。
- その `version` と全 platform の release URL が対象版を指す。
- 対象ブロックに旧版の URL や checksum の取り残しがない。
- private repository の参照が混入していない。
- `mise-lock-update` が定める platform 数と `chezmoi diff` の確認を満たす。

## 導入結果と完了条件

最後の apply 後に `mise current aqua:openai/codex` と `codex --version` を実行し、導入版が対象版であることを確認する。PATH alias 作成の警告だけでバージョンが一致する場合は警告と成功を分けて報告する。

次がすべて成立したときだけ完了とする。

- config と source lock が対象版で一致している。
- lock の Codex platform 情報が再生成済みである。
- apply 後の `codex --version` が対象版である。
- `chezmoi diff` が `mise-lock-update` の基準で収束している。

完了報告には旧版→新版、changelog の重要点、変更ファイル、検証結果を含める。適用前の報告とコミットの分担は source root の `AGENTS.md` に従う。
