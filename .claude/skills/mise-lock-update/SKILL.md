---
name: mise-lock-update
description: |
  この dotfiles リポジトリで mise のツールを追加・削除・バージョン変更したあと、`~/.config/mise/mise.lock` を `dot_config/mise/private_mise.lock` へ同期してコミットするまでの手順。`mise lock -g` を挟む理由、private 参照の混入チェック、そして同期後の `chezmoi diff` が空にならず run_onchange スクリプトのハッシュ差分として現れる挙動を扱う。
when_to_use: |
  triggered by "mise lock", "mise.lock", "lockfile 更新", "lockfile を同期", "private_mise.lock", "mise にツールを追加", "mise のツールを更新", "mise のバージョンを上げた", "aqua でツールを入れた", "chezmoi diff が空にならない", "install-mise-tools.sh が diff に出る", "差分が無いのに apply 対象", "/mise-lock-update"
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
- **削除済みツールのエントリが残る** — `[tools]` から消しても lockfile 側は掃除されない

`mise lock -g` は全 platform 分を再解決し、不要なエントリを落とす。だから `install` の後に必ず挟む。

`mise.lock` は **生成物**。手で編集せず、必ず `mise lock -g` で再生成すること。

## 実行分担

このリポジトリの方針（CLAUDE.md）により、home への適用操作はユーザーが実行する。

| 操作 | 実行者 |
|---|---|
| `dot_config/mise/config.toml.tmpl` の編集 | Claude |
| `chezmoi apply` | **ユーザー** |
| `mise lock -g`（`~/.config/mise/mise.lock` を書き換える） | **ユーザー** |
| `cp` で source へ同期（source ファイルの更新） | Claude |
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
chezmoi diff        # ← 空にはならない。次章を読むこと

# 5. もう一度 apply して収束させる → コミット
chezmoi apply -v    # mise install が冪等に再実行され、diff が静かになる
```

## 同期後の `chezmoi diff` は「空」にならない

**ここが最大の落とし穴。** 手順 4 の `chezmoi diff` は空にならず、`install-mise-tools.sh` が `new file mode 100755` として全文表示される。

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

- **`.config/mise/mise.lock` のファイル差分が出ないこと** — 出るなら `cp` が効いていない（コピー元/先を間違えている）
- **`install-mise-tools.sh` だけが出ていること** — 他のファイル差分が混ざっていたら、それは lockfile 同期とは別の未適用変更
- **手順 5 の再 apply で diff が 0 行に収束すること** — `mise install` は既にインストール済みなので実質 no-op。chezmoi が新しいスクリプトハッシュを記録して静かになる

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
- [ ] `chezmoi diff` で `.config/mise/mise.lock` のファイル差分が**出ていない**か
- [ ] 再 apply して diff が 0 行に収束したか（手順 5）
- [ ] コミットに `dot_config/mise/config.toml.tmpl` と `dot_config/mise/private_mise.lock` の両方が含まれているか
