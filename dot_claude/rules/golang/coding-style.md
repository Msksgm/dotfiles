# Go コーディングスタイル

> このファイルは `@rules/coding-style.md` を Go 固有の内容で拡張する。

## フォーマット

- **gofmt** と **goimports** は必須 — スタイル議論の余地なし

## 設計原則

- interface を受け取り、struct を返す
- interface は小さく保つ（1〜3 メソッド）
- interface は実装側ではなく**使用側**で定義する

## エラーハンドリング

エラーには必ずコンテキストを付けてラップすること:

```go
if err != nil {
    return fmt.Errorf("failed to create user: %w", err)
}
```
