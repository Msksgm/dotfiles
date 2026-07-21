---
name: plan-to-html
description: plan を HTML でも出力する。Claude Code の plan（~/.claude/plans/ 配下の Markdown）を、外部依存のない単一 HTML ファイルに変換する。「plan を html で」「プランを HTML 出力」「plan を html でも出力」等で発火。また、plan の md にユーザーの指摘を反映して改訂した際、同ディレクトリに同名 .html が既に存在する場合はその HTML も再生成して同期する。
---

指定された plan の `.md` ファイルを、同ディレクトリ・同basename・拡張子 `.html` の単一 HTML ファイルとして書き出す。

## 手順

### 1. 対象 `.md` の特定

- 引数や会話内でファイルパスが明示されていればそれを使う。
- 未指定のときは、カレントセッションの plan ファイル（セッション開始時に書き出された `~/.claude/plans/<slug>.md`）を使う。
- それも不明なときは `~/.claude/plans/` 内を mtime 降順で確認し、最新の `.md` を使う。
- それでも特定できなければユーザーに確認する。

### 2. 雛形の読み込み

スキルフォルダ内の `template.html` を Read ツールで読み込む。`<!-- TITLE -->` と `<!-- CONTENT -->` の 2 箇所だけ差し替える。`<style>`・テーマ切り替えボタン（`.theme-toggle`）・インライン `<script>` はそのまま流用する。

### 3. Markdown → HTML 変換

**元の `.md` は変更しない。** 以下の規約で HTML を構築する。

#### 基本規則

- `<` `>` `&` は必ず HTML エスケープ（`&lt;` `&gt;` `&amp;`）
- 外部依存ゼロ（外部 CSS/画像/Web フォント/CDN なし）。JS は `template.html` 同梱のテーマ切り替え用インラインスクリプトのみ
- `[[memory-token]]` 等のメモリ参照記法は素のテキストとしてレンダリング

#### 要素変換

| Markdown | HTML |
|---|---|
| `# タイトル` | `<h1>タイトル</h1>` |
| タイトル直後のサブタイトル的な行 | `<p class="meta">…</p>` |
| `## 見出し` | `<h2 id="…"><span class="num">N</span>見出し</h2>`（N は 1 起算の連番） |
| `### 見出し` | `<h3>見出し</h3>` |
| 「新規」「NEW」が含まれる h3 | `<span class="tag new">NEW</span>` を h3 に追加 |
| 「編集」「EDIT」「変更」が含まれる h3 | `<span class="tag edit">EDIT</span>` を h3 に追加 |
| `**太字**` | `<strong>太字</strong>` |
| `` `インラインコード` `` | `<code>インラインコード</code>` |
| コードブロック（` ``` `） | `<pre><code>…</code></pre>` |
| `- リスト` / `* リスト` | `<ul><li>…</li></ul>` |
| `1. リスト` | `<ol><li>…</li></ol>` |
| `---` 区切り | `<hr>` |
| `[text](url)` | `<a href="url">text</a>` |
| テーブル（`|…|`） | `<table><tr><th>…</th></tr>…</table>` |
| 段落 | `<p>…</p>` |

#### 目次の自動生成

`<h2>` 見出しを全て収集し、ドキュメント冒頭（`<h1>` の直後）に以下の形式で挿入する:

```html
<div class="toc">
  <strong>目次</strong>
  <ol>
    <li><a href="#id1">見出し1</a></li>
    <li><a href="#id2">見出し2</a></li>
  </ol>
</div>
```

`h2` の `id` は見出しテキストを ASCII slug 化（スペース→`-`、記号除去、小文字）または連番（`section-1`, `section-2` …）で生成し、目次アンカーと一致させる。

#### callout ブロック

`> ` 引用ブロックは通常 callout として扱う:

```html
<div class="callout"><p>…</p></div>
```

`> ⚠` / `> **注意**` / `> **警告**` で始まる場合は warn:

```html
<div class="callout warn"><p>…</p></div>
```

### 4. HTML の組み立て

`template.html` の 2 箇所のプレースホルダを置換する:

- `<!-- TITLE -->` → plan のタイトル文字列（HTML エスケープ済み）
- `<!-- CONTENT -->` → 手順 3 で変換した本文 HTML

`<style>`・テーマ切り替えボタン・`<script>` は template.html のものをそのまま使うため、生成 HTML には自動的に含まれる。

### 5. 書き出し

- 出力先: `<入力 .md と同じディレクトリ>/<同じ basename>.html`
- 同名 HTML が存在する場合は**上書き**する
- Write ツールで書き出す

### 6. 完了報告

生成した HTML の絶対パスをユーザーに報告する。

## plan 更新時の HTML 同期

ユーザーの指摘やレビューを反映して plan の `.md` を改訂した場合、**同ディレクトリに同 basename の `.html` が既に存在するときに限り**、手順 2〜5 をそのまま再実行して `.html` を同期する。

- **対象外**: 同名 `.html` が存在しない plan。この場合は HTML を新規作成せず、何もしない（同期対象は「過去に一度でも HTML 出力した plan」のみ）。
- **同期方法**: 改訂後の `.md` 全文を手順 2〜5 の変換規約でそのまま HTML に変換し直し、既存の `.html` を上書きする。差分パッチではなく全文再生成とする（`.md` が正本、`.html` は常にその写像）。
- **報告**: 同期した `.html` の絶対パスを一言添える。
