---
name: mise-lock-update
description: |
  この dotfiles リポジトリで mise のツールを追加・削除・バージョン変更・リネームしたあと、`~/.config/mise/mise.lock` を `dot_config/mise/private_mise.lock` へ同期してコミットするまでの手順。`mise lock -g` を挟む理由、`mise lock` がエントリを削除しないため削除・リネーム時は残骸ブロックを手で消す必要があること、private 参照の混入チェック、そして同期後の `chezmoi diff` が空にならず run_onchange スクリプトのハッシュ差分として現れる挙動を扱う。
when_to_use: |
  triggered by "mise lock", "mise.lock", "lockfile 更新", "lockfile を同期", "private_mise.lock", "mise にツールを追加", "mise のツールを更新", "mise のバージョンを上げた", "mise のツールを削除", "mise のツールをリネーム", "バックエンドを変えた", "aqua でツールを入れた", "lockfile に古いエントリが残る", "mise lock で消えない", "chezmoi diff が空にならない", "install-mise-tools.sh が diff に出る", "差分が無いのに apply 対象", "/mise-lock-update"
allowed-tools:
  - Read
  - Bash
  - Edit
argument-hint: "[追加/変更したツール名]（省略時は現在の差分から判断）"
user-invocable: true
---

# mise-lock-update

`dot_config/mise/config.toml.tmpl` の `[tools]` を触ったあと、lockfile を source へ同期してコミットするまでの手順。

**入力情報**: $ARGUMENTS

## なぜ `mise lock -g` が要るのか

`chezmoi apply` が走らせる `mise install` だけでは不十分。

- **現在の platform 分しか lock されない** — 他マシン（linux / x64）用の URL と checksum が書かれない

`mise lock -g` は全 platform 分を再解決する。だから `install` の後に必ず挟む。

`mise.lock` は原則 **生成物**。バージョンや checksum を手で書き換えず、`mise lock -g` に再生成させること。**唯一の例外がツール削除・リネーム時の残骸除去**で、これは次章のとおり手で消すしかない。

## `mise lock` はエントリを削除しない（ツール削除・リネーム時の必須手順）

**`mise lock -g` は refresh 専用で、lockfile から不要なエントリを落とす機能を持たない。** `[tools]` から消したツール、リネームで旧キーが不要になったツールのエントリは、放っておくと lockfile に残り続ける。

根拠:

- `mise lock --help` は "Updates checksums and download URLs for **all platforms already specified in the lockfile**" とあるだけで、削除・prune 系のオプションが存在しない
- 実行ログが `→ Processing N tool(s)` として走査するのは **config 側にあるツールだけ**。lockfile にしか無いエントリは参照すらされない
- `mise uninstall <tool>@<version>` で install 実体を消しても lockfile のエントリは残る
- `mise prune` は **installs 専用**。lockfile には触れないうえ、無関係な他ツールの旧バージョンまで巻き込むので、この用途では使わないこと

実例（2026-08-02、terraform を短縮名 `terraform` から明示記法 `aqua:hashicorp/terraform` へ移行したとき）: config を書き換えて `chezmoi apply` → `mise uninstall terraform@1.14.1` → `mise lock -g` を 2 回走らせても、旧 `[[tools.terraform]]` 1.14.1 のブロックは最後まで残った。

### 対処

`cp` で source へ同期したあと、**source 側の `dot_config/mise/private_mise.lock` から旧ブロックを手で削除する**。

```sh
# 1. 残骸が無いか確認する（config に無いツール名が出たら残骸）
grep -n '^\[\[tools\.' dot_config/mise/private_mise.lock

# 2. 旧ブロックの範囲を特定する。[[tools.<旧名>]] から次の [[tools. の直前まで
awk '/^\[\[tools\.<旧名>\]\]/{s=NR} s&&NR>s&&/^\[\[tools\./{print s" - "NR-1; exit}' \
  dot_config/mise/private_mise.lock

# 3. その範囲を削除したあと、検証する
grep -c '<旧バージョン>' dot_config/mise/private_mise.lock   # → 0 であること
yq -p toml -o json '.tools | keys' dot_config/mise/private_mise.lock | grep -i '<ツール名>'
```

削除後は **source のほうが正**になる。`~/.config/mise/mise.lock` は chezmoi 管理下（`.chezmoiignore` 対象外）なので、次の `chezmoi apply` で source のクリーンな lock が home 側へ上書きされ、live の残骸も同時に消える。

このとき `chezmoi diff` に `.config/mise/mise.lock` のファイル差分が出るのは**正常**。通常は「差分が出たら `cp` の方向ミス」だが、手削除した直後だけは例外で、差分の内容が旧ブロックの削除だけであることを確認して apply する。

## 実行分担

このリポジトリの方針（CLAUDE.md）により、home への適用操作はユーザーが実行する。

| 操作 | 実行者 |
|---|---|
| `dot_config/mise/config.toml.tmpl` の編集 | Claude |
| `chezmoi apply` | **ユーザー** |
| `mise uninstall`（ツール削除・リネーム時のみ） | **ユーザー** |
| `mise lock -g`（`~/.config/mise/mise.lock` を書き換える） | **ユーザー** |
| `cp` で source へ同期（source ファイルの更新） | Claude |
| source lock からの残骸ブロック手削除（ツール削除・リネーム時のみ） | Claude |
| 検証コマンド（read-only） | Claude |
| コミット | **ユーザー** |

ユーザーに実行を依頼するときは `! <command>` をプロンプトに打てばこのセッションに出力が返ることを案内する。

## 手順

```sh
# 1. dot_config/mise/config.toml.tmpl の [tools] を編集したあと
chezmoi apply -v    # run_onchange が mise install を実行する

# 2. 全プラットフォーム分の URL/checksum を再解決する
#    ※ GITHUB_TOKEN は必須。未認証だと 60 req/h で即座にレート制限に当たり、
#      403 で取りこぼした platform エントリが歯抜けのまま lock に書かれる
export GITHUB_TOKEN="$(gh auth token)"
mise lock -g

#    取りこぼしが無いか確認する（7 未満は上流が全 platform を配布していない場合もある）
awk '/^\[\[tools\./{n++; c[n]=0} /^\[tools\..*platforms\./{c[n]++} \
  END{f=0; for(i=1;i<=n;i++) if(c[i]>=7) f++; print f" / "n" tools with 7 platforms"}' ~/.config/mise/mise.lock

# 3. private な参照が混ざっていないか確認（owner が全部 public であること）
grep -o 'github\.com/[^/]*/[^/"]*' ~/.config/mise/mise.lock | sort -u

# 4. source へ同期する
cp ~/.config/mise/mise.lock "$(chezmoi source-path)/dot_config/mise/private_mise.lock"

# 5. ツールを削除・リネームした場合のみ: 残骸ブロックを source から手で消す
#    mise lock はエントリを削除しないので、これをやらないと旧エントリが public repo に残る
grep -n '^\[\[tools\.' dot_config/mise/private_mise.lock   # config に無い名前が出たら残骸
#    → 「`mise lock` はエントリを削除しない」章の手順で削除する

chezmoi diff        # ← 空にはならない。次章を読むこと

# 6. もう一度 apply して収束させる → コミット
chezmoi apply -v    # mise install が冪等に再実行され、diff が静かになる
```

## 同期後の `chezmoi diff` は「空」にならない

**ここが最大の落とし穴。** 同期後の `chezmoi diff` は空にならず、`install-mise-tools.sh` が `new file mode 100755` として全文表示される。

```
diff --git a/install-mise-tools.sh b/install-mise-tools.sh
new file mode 100755
...
+# config hash: f8f4a153e8de830474a385eb4046fce1669cec2d2349f2381bac16b14418069c
+# lockfile hash: d381e5c0b4b2e11a2ff5169be52cdf8072fbafe007156df98c9ea6d59171b15e
```

これは**ファイルの差分ではなく「apply したらこのスクリプトが走る」という予告**。`chezmoi diff` はファイル差分と実行予定スクリプトの両方を出力し、スクリプトは home に残る成果物ではないので比較相手が存在せず、常に new file として全文が出る。

走る判定になる仕組み:

1. `run_onchange_after_install-mise-tools.sh.tmpl` は先頭コメントに source ファイルの sha256 を **4 本**埋め込んでいる（`config hash:` / `private config hash:` / `private tool version hash:` / `lockfile hash:`）。
2. 手順 4 の `cp` で lockfile の中身が変わると `lockfile hash:` 行の値が変わる → スクリプトのレンダリング結果そのものが変わる。
3. chezmoi は state DB に「実行済みスクリプトの内容ハッシュ」を保持している。新しい内容ハッシュは未登録なので、`run_onchange_` の定義どおり再実行対象になる。

### 正しい確認観点

「diff が空か」ではなく、次の 3 点を見る。

- **`.config/mise/mise.lock` のファイル差分が出ないこと** — 出るなら `cp` が効いていない（コピー元/先を間違えている）。**ただし手順 5 で残骸ブロックを手削除した直後だけは例外**で、その削除分の差分が出るのが正しい。差分の中身が旧ブロックの削除だけであることを確認して apply する
- **`install-mise-tools.sh` だけが出ていること** — 他のファイル差分が混ざっていたら、それは lockfile 同期とは別の未適用変更
- **手順 6 の再 apply で diff が 0 行に収束すること** — `mise install` は既にインストール済みなので実質 no-op。chezmoi が新しいスクリプトハッシュを記録して静かになる

### 診断レシピ

「なぜ apply 対象なのか」を確定させたいときは以下を順に実行する（すべて read-only）。

```sh
# a. 埋め込みハッシュと実ファイルが一致しているか
#    → 出た値がスクリプト内の `# lockfile hash:` 行と一致するはず
shasum -a 256 dot_config/mise/private_mise.lock

# b. これから走るスクリプトの内容ハッシュ
chezmoi execute-template < run_onchange_after_install-mise-tools.sh.tmpl | shasum -a 256

# c. それが実行済みリストに載っているか（載っていなければ apply 対象）
chezmoi state dump | grep <b で出たハッシュ>
```

`c` で何も出なければ「未実行だから apply 対象」で確定。apply 後に同じ `grep` を打つと今度はヒットする。

## `mise lock` の注意点

- **エントリの追加と更新しかしない。削除はしない。** config から消したツールの残骸は手で消すこと（「`mise lock` はエントリを削除しない」章）。
- **既に lockfile にある platform しか更新しない。** 新しく platform を増やすには `-p` で明示する（`mise lock -g -p linux-arm64,linux-arm64-musl,linux-x64,linux-x64-musl,macos-arm64,macos-x64,windows-x64`）。上流が配布していない platform は書かれず、以後その集合が「既存」になるので数は自然に落ち着く。
- **7 未満のツールがあっても異常ではない。** 上流の配布状況次第。実例: `github:sunakan/op-vault` は darwin_arm64 のみなので 1、`aqua:twistedpair/google-cloud-sdk` は `supported_envs: [darwin, linux]` なので 4（windows / musl 無し）。
- **GitHub の build attestation を公開しているツール**（uv / gh / jq / yq / pinact / ghtkn / op-vault 等）は provenance 記録のため **lock のたびにアーティファクト実体をダウンロードする**（キャッシュされない）。実行が遅いのはこれが理由で、異常ではない。
- **`"latest"` は使わない。** lockfile 追跡下では固定されるので自動更新の利点が消える一方、resolve が意図しない古いバージョンを掴むと `mise install` が失敗し続ける（`android-sdk` が `1.0` に固定されて壊れた実例あり）。新規ツールは明示ピンにすること。
- `uv` の `"latest"` を上げたいときは `mise lock -g --bump`（config は書き換えない）を挟んでから手順 4 へ。

## private tool を混ぜないこと

**`dot_config/mise/config.toml.tmpl` に private repo のツールを書かない。** ここの tool は `mise.lock` に載り、その `mise.lock` は public repo で追跡しているため、repo 名だけでなくリリースアセット URL まで漏れる。

private tool は `dot_config/mise/private_config.local.toml.tmpl`（→ `~/.config/mise/config.local.toml`）に書く。lock が追跡対象外の `mise.local.lock` に分離される。`conf.d/*.toml` は lockfile が親の `mise.lock` に合流するので隔離手段にならない。

手順 3 の `grep` は、この隔離が破れていないかの最終チェック。owner に見覚えのない private repo が出たら**コミットせずに**原因を潰すこと。詳細は CLAUDE.md を参照。

## 観点チェックリスト

- [ ] `config.toml.tmpl` の編集後に `chezmoi apply` を済ませたか（手順 1）
- [ ] `GITHUB_TOKEN` を export してから `mise lock -g` したか（手順 2）
- [ ] platform 数のカウントを確認したか。減っているツールがあれば上流の配布状況を確認したか
- [ ] `grep` で owner がすべて public だったか（手順 3）
- [ ] `cp` の方向は home → source か（逆にすると lock が巻き戻る）
- [ ] **ツールを削除・リネームした場合**: source lock に旧エントリの残骸が無いか（`grep -n '^\[\[tools\.'` で config に無い名前が出ないこと。`mise lock` は削除してくれない）（手順 5）
- [ ] `chezmoi diff` で `.config/mise/mise.lock` のファイル差分が**出ていない**か（残骸を手削除した直後のみ、その削除分が出るのが正しい）
- [ ] 再 apply して diff が 0 行に収束したか（手順 6）
- [ ] コミットに `dot_config/mise/config.toml.tmpl` と `dot_config/mise/private_mise.lock` の両方が含まれているか
