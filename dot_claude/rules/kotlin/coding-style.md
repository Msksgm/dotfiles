# Kotlin コーディングスタイル

> このファイルは `@rules/coding-style.md` を Kotlin 固有の内容で拡張する。

## フォーマット

- **ktlint** または **Detekt** でスタイルを強制する
- `gradle.properties` に `kotlin.code.style=official` を設定して公式 Kotlin コードスタイルを使う

## 不変性

- `var` より `val` を優先する — デフォルトは `val` とし、変更が必要な場合のみ `var` を使う
- 値型には `data class` を使い、公開 API では不変コレクション（`List`, `Map`, `Set`）を使う
- 状態更新はコピーオンライト: `state.copy(field = newValue)`

## 命名

Kotlin の慣習に従うこと:
- 関数・プロパティ: `camelCase`
- クラス・インターフェース・オブジェクト・型エイリアス: `PascalCase`
- 定数（`const val` または `@JvmStatic`）: `SCREAMING_SNAKE_CASE`
- インターフェース名には振る舞いを表す接頭辞を使い、`I` は付けない: `IClickable` ではなく `Clickable`

## Null 安全

- `!!` は絶対に使わない — `?.`・`?:`・`requireNotNull()`・`checkNotNull()` を使う
- スコープ付き null 安全操作には `?.let {}` を使う
- 結果が存在しない場合がある関数は nullable 型を返す

```kotlin
// bad
val name = user!!.name

// good
val name = user?.name ?: "Unknown"
val name = requireNotNull(user) { "User must be set before accessing name" }.name
```

## Sealed 型

閉じた状態階層のモデリングには sealed class/interface を使うこと:

```kotlin
sealed interface UiState<out T> {
    data object Loading : UiState<Nothing>
    data class Success<T>(val data: T) : UiState<T>
    data class Error(val message: String) : UiState<Nothing>
}
```

sealed 型に対する `when` は網羅的に書くこと — `else` ブランチを使わない。

## 拡張関数

ユーティリティ操作に拡張関数を使うが、発見しやすさを維持すること:
- レシーバー型にちなんだファイル名にする（`StringExt.kt`、`FlowExt.kt`）
- スコープを限定する — `Any` や過度に汎用的な型に拡張を追加しない

## スコープ関数

適切なスコープ関数を使い分けること:
- `let` — null チェック + 変換: `user?.let { greet(it) }`
- `run` — レシーバーを使って結果を計算: `service.run { fetch(config) }`
- `apply` — オブジェクトの設定: `builder.apply { timeout = 30 }`
- `also` — 副作用: `result.also { log(it) }`
- スコープ関数の深いネストは避けること（最大 2 レベル）

## エラーハンドリング

- `Result<T>` またはカスタム sealed 型を使う
- `runCatching {}` で例外が発生しうるコードをラップする
- `CancellationException` は絶対にキャッチしない — 必ず再スローすること
- 制御フローのために `try-catch` を使わない

```kotlin
// bad — 例外を制御フローに使っている
val user = try { repository.getUser(id) } catch (e: NotFoundException) { null }

// good — nullable を返す
val user: User? = repository.findUser(id)
```
