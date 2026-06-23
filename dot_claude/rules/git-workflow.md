# Git ワークフロー

## コミットメッセージフォーマット

```
<type>: <description>

<optional body>
```

type の種別: feat, fix, refactor, docs, test, chore, perf, ci

## Claude Code によるコミットの帰属

Claude Code がコミットを作成する際は、必ずコミットメッセージの末尾に以下を付与すること:

```
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

## Pull Request ワークフロー

PR を作成する際:
1. 最新コミットだけでなく、ブランチ全体のコミット履歴を確認する
2. `git diff [base-branch]...HEAD` ですべての変更を把握する
3. 包括的な PR サマリーを書く
4. TODO 形式のテスト計画を含める
5. 新規ブランチの場合は `-u` フラグ付きでプッシュする

> 計画・TDD・コードレビューなど git 操作前の開発プロセス全体については
> `@rules/development-workflow.md` を参照すること。
