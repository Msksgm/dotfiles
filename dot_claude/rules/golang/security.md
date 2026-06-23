# Go セキュリティ

> このファイルは `@rules/security.md` を Go 固有の内容で拡張する。

## シークレット管理

環境変数から読み取り、未設定の場合はフェイルファストすること:

```go
apiKey := os.Getenv("OPENAI_API_KEY")
if apiKey == "" {
    log.Fatal("OPENAI_API_KEY not configured")
}
```

## セキュリティスキャン

**gosec** で静的セキュリティ解析を行うこと:

```bash
gosec ./...
```

## コンテキストとタイムアウト

タイムアウト制御には常に `context.Context` を使うこと:

```go
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()
```
