---
name: svg-diagram
description: 通信フロー図・アーキテクチャ図などをアニメーション付きSVGで作る。クライアント/Webサーバー/データベースのノードや、流れるパケット、周回する点といった部品テンプレートを組み合わせて生成する。「SVG図を作って」「svgテンプレート」「パケットフロー図」「シーケンス図をsvgで」「クライアント/サーバー/DBの図」「動的な図を作って」等で発火。
---

ブログ記事や Markdown ドキュメントに貼り付けられる、外部依存ゼロの SVG 図を作る skill。個々の要素（部品）を `components/` に持ち、それらを組み合わせた完成イメージを `examples/` に持つ。

## テンプレート一覧

### components/（部品 — 組み合わせて使う）

| ファイル | 内容 |
|---|---|
| `components/client-node.html` | クライアント（ブラウザ）アイコン |
| `components/webserver-node.html` | Webサーバー（LED点滅 + パルスリング付き） |
| `components/database-node.html` | データベース（シリンダー + パルスリング付き） |
| `components/packet.html` | 経路に沿って流れ続ける光る粒子（animateMotion + mpath） |
| `components/orbiting-dot.html` | 円 + 円周を周回する点（モーションの基本例） |

### examples/（完成イメージ — そのまま使う／土台にする）

| ファイル | 内容 | 元になった部品 |
|---|---|---|
| `examples/sequence-diagram.html` | レーン式の静的シーケンス図（①〜④の番号付き矢印） | client-node, webserver-node, database-node |
| `examples/packet-flow.html` | 常時パケットが流れ続ける動的フロー図 | client-node, webserver-node, database-node, packet |

## 手順

1. **要件を聞く**: 何と何の間の、どんな通信・データフローを図示したいか（静的な手順図か、常時動くフロー図か）を確認する。
2. **土台を選ぶ**:
   - 完成イメージに近いものがあれば `examples/` のファイルを Read し、それを土台にノード名・ラベル・配色・タイミングを書き換える。
   - 既存の完成イメージに当てはまらない構成（ノード数が違う、レイアウトが違う等）なら、`components/` から必要な部品を選んで Read し、新しく組み立てる。
3. **部品を組み合わせる**:
   - 各部品はローカル座標（原点付近）に置かれた自己完結の断片。`<g transform="translate(X,Y)">` で好きな位置に配置する。
   - `packet.html` の粒子を使う場合、経路 `<path id="...">` と参照する `<mpath href="#...">` は、他の経路と衝突しないユニークな id にリネームする。
   - 色は各部品の `<style>` 内 CSS 変数（`--ink` `--muted` `--surface` `--request` `--response` 等）を参照する形になっている。組み合わせる際は変数名をそろえ、1つの `<style>` ブロックにまとめてよい。
4. **配色・ダークテーマの方針を守る**:
   - 色は CSS 変数で持ち、`@media (prefers-color-scheme: dark)` で再定義する（固定の直値だけにしない）。
   - CSS 変数・セレクタは `:root` ではなく、ラッパー要素につけたクラス（例 `.wsdb-xxx`）にスコープする。貼り付け先ページの他の要素や、同一ページ内の別テンプレートと衝突させないため。
   - アニメーションは SMIL（`animate` / `animateMotion`）のみを使う。外部 JS/CSS/CDN には依存しない。
5. **出力先を決めて書き出す**:
   - プレビュー用: `<!DOCTYPE html>` から始まる単体 HTML（中央寄せの `body` に SVG を配置）。
   - 貼り付け用: `<figure class="wsdb-...">...</figure>` や `<svg>...</svg>` のスニペットだけを抜き出し、ユーザーが Markdown に直接貼れる形で提示する。
   - Write で書き出し、絶対パスを報告する（貼り付け用スニペットの場合は加えてコードブロックとしても提示する）。

## 制約・注意点

- **skill 自体の更新は dotfiles の source を編集する**。`~/.agents/skills/svg-diagram/`（`~/.claude/skills/svg-diagram/` はそこへの symlink 経由）は生成物なので直接編集しない。テンプレートの追加・修正は `~/workspace/github.com/Msksgm/dotfiles/dot_agents/skills-local/svg-diagram/` を編集し、`run_onchange_after_install-local-skills.sh.tmpl` の `local-skill hash:` 行に該当ファイルを追記する（`chezmoi apply` はユーザーが実行する）。
- 生成する SVG に外部フォント・外部画像・CDN・トラッキングスクリプトを含めない。
- 1ページに複数テンプレートを貼る可能性があるため、`id` とスコープ用クラス名は使い回さずユニークにする。
