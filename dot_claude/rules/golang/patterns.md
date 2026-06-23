# Go パターン

> このファイルは `@rules/patterns.md` を Go 固有の内容で拡張する。

## Functional Options パターン

```go
type Option func(*Server)

func WithPort(port int) Option {
    return func(s *Server) { s.port = port }
}

func NewServer(opts ...Option) *Server {
    s := &Server{port: 8080}
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

## 小さい interface

interface は実装側ではなく、使用される場所で定義すること。

## 依存性の注入（DI）

コンストラクタ関数で依存を注入すること:

```go
func NewUserService(repo UserRepository, logger Logger) *UserService {
    return &UserService{repo: repo, logger: logger}
}
```
