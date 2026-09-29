---
name: herdr-version-update
description: >-
  この dotfiles リポジトリで mise/aqua 管理の herdr を指定版または最新安定版へ更新する。
  公式リリース確認、version pin の編集、lock の検証、導入版と稼働中サーバーの確認、live handoff の案内を行う。
  「herdr を更新して」「herdr を最新版に」で使用する。他の導入方式や herdr 自体の開発には使わない。
---

# herdr version update

## 管理元を確認する

- `chezmoi source-path ~/.config/mise/config.toml` と `chezmoi source-path` で管理元と source root を特定する。source root の `AGENTS.md` を読み、適用・コミットの共通ルールに従う。
- 以下のパスはすべて source root 基準。インストールされたこのスキルの相対パスから推測しない。
- `git status` と差分を確認して既存変更を保持する。現在の pin は `dot_config/mise/config.toml.tmpl` の `"aqua:ogulcancelik/herdr"`。上流の owner が異なっていても backend 名を更新に便乗して変更しない。
- herdr 本体の更新と、上流の agent skill・integration hook の更新を区別する。後者はリリースの互換性要件に関係するときに調査し、必要な source 変更を説明する。

## 対象版と互換性を確認する

- 指定版があればそれを使い、指定がなければ [公式 releases](https://github.com/herdrdev/herdr/releases/latest) で最新安定版を確認する。tag、公開日時、draft/prerelease の状態を確認し、config には `v` を除いた明示バージョンを使う。prerelease は明示的な依頼がある場合のみ対象とする。
- 現在版から対象版までのリリースノートを読み、設定・API・hook・live handoff の互換性や配布変更を確認する。関連箇所は `dot_config/herdr/`、`dot_zsh/herdr.zsh`、`dot_claude/` などから実際の利用を調べる。
- pin が既に対象版でも、更新完了と即断しない。lock、導入バイナリ、稼働中サーバーが異なる場合は、残った段階から進める。

## Source と lock を更新する

1. config の herdr の値を対象版へ変更する。backend、並び、無関係な設定は保持する。
2. `git diff --check`、テンプレートのレンダリングと TOML の解析、`chezmoi diff` で意図した変更を確認する。
3. source root の `.agents/skills/mise-lock-update/SKILL.md` を読み、適用・lock 生成・検証・同期・再適用の実行分担と順序に従う。生成物の version・URL・checksum を手で書き換えない。
4. ユーザーの完了報告後は、home と source の実際の状態から済んだ段階を判定する。「反映した」だけで lock 同期まで完了したとみなさない。
5. lock の herdr ブロックが1件で、version と配布 URL が対象版であること、platform の欠落や private 参照の混入がないことを確認する。上流の配布対象と比較し、常に7 platform と固定しない。TOML 解析時は `platforms.linux-arm64` などが引用された単一キーである点に注意する。

## 導入と稼働中サーバーを分けて検証する

```sh
herdr_bin="$(mise which herdr)"
"$herdr_bin" --version
"$herdr_bin" status server
```

更新前から開いているシェルの PATH は旧版を指す場合がある。`herdr --version` 単独では導入失敗と判断しない。名前付きセッションは `--session "名前"` を付けて確認し、通常セッションの結果から全セッションの更新を断定しない。

導入版とサーバー版が異なる場合は、source root の `docs/herdr-live-update.md` を読み、対象版の CLI と公式説明に照らして手順を案内する。既に対象版なら再引き継ぎは不要。停止済みなら新版での起動を案内する。接続失敗を停止済みと同一視しない。

live handoff は接続中のクライアントや処理中の API 呼び出しを中断しうるため、herdr の外側のターミナルからユーザーが実行する。これはサーバー切り替えに対する追加の実行分担である。失敗時は状態とエラーを確認し、通常の停止へ自動的に切り替えない。mise 管理では `herdr update --handoff` を使わない。

## 完了報告

旧版→対象版、リリースの関連変更、編集ファイルと検証結果を伝える。次の状態を区別する。

- source の config と lock が一致している。
- ユーザーの適用後、mise が選択するバイナリが対象版であり、関連する chezmoi 差分が収束している。
- 対象セッションのサーバーが対象版であり、ユーザーが再接続後のペイン・作業の引き継ぎを確認している。

未実施・未確認の段階は明記する。無関係な chezmoi 差分を更新失敗と扱わず、追加変更やコミットへ混ぜない。
