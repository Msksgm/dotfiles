# Deferred features from the referenced workflow

この文書は通常の PR レビュー手順では読み込まない。図解機能の追加、記事掲載版との比較、または upstream の未採用機能を再検討するときだけ参照する。

参考元:

- https://dev.classmethod.jp/articles/pr-review-judgment-left-after-ai/#%E3%82%B9%E3%82%AD%E3%83%AB%E5%85%A8%E6%96%87

## 現在の状態

現在の `pr-critical-review` は Markdown のみを生成する。以下は記事掲載版に含まれるが、実行に必要な図解用2ファイルが記事では公開されていない、または読み取り専用のレビュー方針と合わないため有効化していない。

ここに記録した内容は将来の設計材料であり、利用可能な機能ではない。必要なファイルがない状態でコマンドやフラグだけを `SKILL.md` に戻さない。

## 図解成果物

記事掲載版は Markdown に加え、同じ HTML 断片から次の2成果物を作る設計だった。

1. Artifact 環境へ非公開で発行する共有用の図解
2. ネットワークなしで開ける単体 HTML ファイル `pr-{番号}-explainer.html`

Markdown は判断とコメントの下書き、HTML はトリアージの全体像と根拠の検証資料、という役割分担を想定している。HTML には次を含める。

- PR の背景を知らない人向けの前提説明
- 疑い、指摘、未確認、閉じた項目の件数
- 「見なくてよい」とした全項目または検証可能な一覧
- 経緯を探索した範囲と未回答の問い
- 変更箇所から影響先までと、探索を閉じた根拠を示す境界図
- PR head の実コードから展開したコード抜粋

自己完結性を保つため Web font や外部 asset に依存しない。境界図が欠けた HTML は、見た目が整っていても探索終了の根拠にならないため公開しない。

## 未採用のインターフェース

記事掲載版には次のフラグがある。

- `--no-visual`: HTML を生成せず Markdown のみ作る。
- `--visual-only`: 既存 Markdown を読み、HTML だけ生成する。

現在は常に Markdown 専用なので、どちらも受け付けない。再導入する場合は、通常実行で図解を既定にするか opt-in にするかを先に決め、description、入力仕様、失敗時の挙動を同時に更新する。

## 欠けているファイルと依存

記事掲載版は次を参照するが、記事中では内容が省略されている。

- `VISUAL.md`: HTML の情報設計、境界図、配色、layout、自己完結性の要件
- `scripts/build-html.py`: コード抜粋展開、構造検証、単体 HTML 化

また、次の実行環境を前提としている。

- Python 3.9 以上
- HTML artifact を設計・公開できる環境
- 記事中の `artifact-design`、`artifact-diagramming` に相当する能力

Codex と Claude Code の双方で同じ結果を得るには、特定製品の Artifact API を必須にせず、単体 HTML を正本として任意の preview/publish adapter を重ねる設計が望ましい。

## 想定されていた HTML build pipeline

記事掲載版の処理は、概ね次の3段階である。

1. `expand`: HTML 断片内の `<!--SRC path start end hi=a-b-->` 形式の指定を、PR head のコード抜粋へ展開する。
2. `validate --strict`: source 指定、行番号、必須 section、境界図、外部依存の禁止などを検査する。失敗時は公開しない。
3. `standalone`: style と本文を埋め込んだ単体 HTML を出力する。

コード抜粋は base や現在の working tree ではなく PR head を参照する必要がある。行番号を手入力せず、source 指定から機械的に展開する。将来スクリプトを実装する場合は、各 subcommand の fixture と失敗ケースを用意する。

## `git fetch` を使う取得経路

記事掲載版は base/head を `git fetch` し、merge base からの diff と head file をローカルで読む経路を持つ。これは正確な行番号と任意ファイル参照に便利だが、`.git` の ref と object store を変更する。

現在版はレビューを読み取り専用として扱うため、自動 fetch を採用していない。再導入するなら次を満たすこと。

- fetch の必要性を先に説明し、ユーザーの許可を得る。
- 取得する remote と ref を明示する。
- 作業ツリーを切り替えない。
- head OID を GitHub の PR メタデータと照合する。
- fetch 不可時は GET の `gh api`、最後に diff hunk の推定行番号へ段階的に落とす。

## 外部環境の限定照会

記事掲載版は AWS の一部 read API をコマンド単位で許可し、コードと実環境の食い違いを確認する設計を含む。実行日、account/profile、実行コマンドを根拠へ残し、許可リスト外は実行しない。

現在版では cloud、database、外部サービスへの CLI 照会をすべて未採用とした。read 系でも料金、容量消費、state lock、監査影響があり得るためである。将来再導入する場合は、provider ごとに次を確認する。

- 公式仕様上の副作用と課金
- 必要最小権限
- account/project/region の取り違え防止
- 実行前の明示承認
- 結果の取得日時と実行主体の記録
- 再現不能になった結果の失効条件

コマンド名の `get`、`list`、`describe` や、plan/diff という語だけで安全と判定しない。

## 再導入チェックリスト

図解または外部環境照会を有効にするときは、次を一括して行う。

1. 欠けている仕様を独自実装するか、利用条件を確認した正規の配布元から取得する。
2. Codex と Claude Code の双方で使える interface と fallback を決める。
3. `SKILL.md` の成果物、入力、安全性、failure mode を更新する。
4. 新規ファイルを `run_onchange_after_install-local-skills.sh.tmpl` の hash 行へ1ファイルずつ追加する。
5. README の管理対象説明と、必要なら mise の依存管理を更新する。
6. HTML builder の正常系、source 不在、範囲外行番号、境界図欠落、外部 asset 混入をテストする。
7. 実在 PR で Markdown と HTML の件数・根拠が一致することを確認する。
