# Kotlin セキュリティ

> このファイルは `@rules/security.md` を Kotlin および Android/KMP 固有の内容で拡張する。

## シークレット管理

- APIキー・トークン・認証情報をソースコードに絶対にハードコードしないこと
- ローカル開発のシークレットには `local.properties`（git 管理外）を使う
- リリースビルドでは CI シークレットから生成された `BuildConfig` フィールドを使う
- 実行時のシークレット保存には `EncryptedSharedPreferences`（Android）または Keychain（iOS）を使う

```kotlin
// bad
val apiKey = "sk-abc123..."

// good — ビルド時に生成される BuildConfig から取得
val apiKey = BuildConfig.API_KEY

// good — 実行時にセキュアストレージから取得
val token = secureStorage.get("auth_token")
```

## ネットワークセキュリティ

- HTTPS のみ使用すること — `network_security_config.xml` で平文通信をブロックする
- 機密性の高いエンドポイントには OkHttp `CertificatePinner` または Ktor 相当でサーバー証明書をピン留めする
- すべての HTTP クライアントにタイムアウトを設定すること — デフォルト（無制限の場合がある）に頼らない
- サーバーレスポンスは使用前に検証・サニタイズすること

```xml
<!-- res/xml/network_security_config.xml -->
<network-security-config>
    <base-config cleartextTrafficPermitted="false" />
</network-security-config>
```

## 入力バリデーション

- ユーザー入力はすべて処理・送信前に検証すること
- Room/SQLDelight ではパラメータ化クエリを使う — ユーザー入力を SQL に連結しないこと
- パストラバーサルを防ぐため、ユーザー入力のファイルパスをサニタイズすること

```kotlin
// bad — SQLインジェクション
@Query("SELECT * FROM items WHERE name = '$input'")

// good — パラメータ化
@Query("SELECT * FROM items WHERE name = :input")
fun findByName(input: String): List<ItemEntity>
```

## データ保護

- Android での機密な key-value データには `EncryptedSharedPreferences` を使う
- `@Serializable` では明示的なフィールド名を使う — 内部プロパティ名を漏洩させない
- 不要になった機密データはメモリから消去すること
- 名前マングリングを防ぐため、シリアライズ対象クラスには `@Keep` または ProGuard ルールを追加する

## 認証

- トークンはプレーンな SharedPreferences ではなくセキュアストレージに保存すること
- 401/403 を適切に処理したトークンリフレッシュを実装すること
- ログアウト時にすべての認証状態をクリアすること（トークン・キャッシュされたユーザーデータ・クッキー）
- 機密操作には生体認証（`BiometricPrompt`）を使う

## ProGuard / R8

- シリアライズ対象モデル（`@Serializable`、Gson、Moshi）に Keep ルールを設定すること
- リフレクションベースのライブラリ（Koin、Retrofit）に Keep ルールを設定すること
- リリースビルドでテストすること — 難読化でシリアライズが静かに壊れる場合がある

## WebView セキュリティ

- 明示的に必要な場合を除き JavaScript を無効にする: `settings.javaScriptEnabled = false`
- WebView にロードする前に URL を検証すること
- 機密データにアクセスする `@JavascriptInterface` メソッドを公開しないこと
- `WebViewClient.shouldOverrideUrlLoading()` でナビゲーションを制御すること
