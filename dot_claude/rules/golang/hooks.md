# Go Hooks

> このファイルは `@rules/hooks.md` を Go 固有の内容で拡張する。

## PostToolUse フック

`~/.claude/settings.json` で設定すること:

- **gofmt/goimports**: `.go` ファイル編集後に自動フォーマット
- **go vet**: `.go` ファイル編集後に静的解析を実行
- **staticcheck**: 変更されたパッケージに対して拡張静的解析を実行
