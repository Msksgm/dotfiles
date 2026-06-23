# Go テスト

> このファイルは `@rules/testing.md` を Go 固有の内容で拡張する。

## フレームワーク

標準の `go test` と**テーブル駆動テスト**を使うこと。

## 競合状態の検出

常に `-race` フラグを付けて実行すること:

```bash
go test -race ./...
```

## カバレッジ

```bash
go test -cover ./...
```
