# CLI ツール管理

- ユーザーレベルの CLI ツールは、原則として chezmoi の dotfiles リポジトリを通じて mise で管理する。
- グローバルな CLI ツールを追加・更新・削除する前に、`chezmoi source-path ~/.config/mise/config.toml` で source を特定し、そのリポジトリの指示を確認する。Homebrew や個別インストーラーは、リポジトリで定めた例外に限る。
- プロジェクトローカルの依存関係には適用せず、各プロジェクトの manifest と instruction file に従う。
