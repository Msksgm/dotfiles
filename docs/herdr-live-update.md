# 起動中の herdr を新版へ引き継ぐ手順

mise で新版を導入しても、起動中の herdr サーバーは旧版のままです。導入済みの新版を指定して live handoff を行います。

特定のバージョン番号に依存しない、mise 管理のローカルセッション向け手順です。対象バージョンへの設定更新・インストールと chezmoi の適用が完了していることを前提とします。対象バージョンは dotfiles の `dot_config/mise/config.toml.tmpl` にある herdr の pin で確認してください。

更新元・更新先が live handoff に対応していることを、対象リリースの説明と CLI で確認してください。将来のバージョンでも互換性があることを保証する手順ではありません。

> live handoff は実験的機能です。成功すればペイン内のプロセスを維持できますが、クライアント接続や処理中の API リクエストが切断される場合があります。大事な作業は事前に保存してください。

## 通常のセッション

### 1. herdr の外側で、新しいターミナルを開く

以降のコマンドは同じターミナルで実行します。

### 2. 導入済みの新版を確認する

```sh
herdr_bin="$(mise which herdr)"
"$herdr_bin" --version
```

表示されたバージョンが対象バージョンと一致することを確認します。旧版が表示された場合は、先に mise の設定と導入状況を確認してください。

```sh
"$herdr_bin" status server
```

既にサーバーも対象バージョンなら引き継ぎは不要です。サーバーが停止済みなら手順 5 で起動します。接続エラーの場合は停止済みと決めつけず、原因を確認してください。

### 3. 起動中のサーバーを新版へ引き継ぐ

```sh
"$herdr_bin" server live-handoff --import-exe "$herdr_bin"
```

`live handoff complete` と表示されることを確認します。エラーの場合は、その内容を確認してから次へ進んでください。

### 4. サーバーのバージョンを確認する

```sh
"$herdr_bin" status server
```

サーバーの `version` が手順 2 の対象バージョンと一致することを確認します。

### 5. 新版クライアントで再接続する

```sh
"$herdr_bin"
```

ペインと実行中の処理が引き継がれていることを確認します。

## 名前付きセッションの場合

手順 2 の事前確認も含め、同じ名前のセッションを指定します。`セッション名` は実際の名前に置き換え、以下を一つずつ実行して通常のセッションと同じ確認を行ってください。

```sh
"$herdr_bin" --session "セッション名" status server
"$herdr_bin" --session "セッション名" server live-handoff --import-exe "$herdr_bin"
"$herdr_bin" --session "セッション名" status server
"$herdr_bin" --session "セッション名"
```

## 補足

- mise 管理では `herdr update --handoff` は使用できません。この手順では、mise で導入済みのバイナリを明示します。
- `herdr --version` は PATH 上のバイナリのバージョンです。更新前から開いているシェルでは旧版を指すことがあるため、この手順では `mise which herdr` で取得したパスを使います。導入済みバイナリと起動中サーバーのバージョンは別々に確認します。
- 引き継ぎに失敗した場合はエラーとサーバーの状態を確認し、停止・再試行を繰り返さないでください。通常の再起動へ切り替える場合は、ペイン内の作業を終了してよいことを先に確認します。
- `herdr server stop` はペイン内のプロセスを終了させるため、live handoff と同じ動作ではありません。

## 参照

- [公式のセッション維持・live handoff の説明](https://herdr.dev/docs/session-state/#live-handoff)
- [公式リリース一覧](https://github.com/herdrdev/herdr/releases)
- コマンド形式の確認元: [v0.9.2 の live-handoff 実装](https://github.com/herdrdev/herdr/blob/v0.9.2/src/cli/server.rs)。更新時には対象バージョンの実装・CLI でも確認してください。
