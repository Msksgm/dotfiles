# Kotlin Hooks

> このファイルは `@rules/hooks.md` を Kotlin 固有の内容で拡張する。

## PostToolUse フック

`~/.claude/settings.json` で設定すること:

- **ktfmt/ktlint**: `.kt` `.kts` ファイル編集後に自動フォーマット
- **detekt**: Kotlin ファイル編集後に静的解析を実行
- **./gradlew build**: 変更後にコンパイルを検証する
