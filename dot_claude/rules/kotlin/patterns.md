# Kotlin パターン

> このファイルは `@rules/patterns.md` を Kotlin および Android/KMP 固有の内容で拡張する。

## 依存性の注入（DI）

コンストラクタ注入を優先すること。Koin（KMP 向け）または Hilt（Android 専用）を使う:

```kotlin
// Koin — モジュールで宣言
val dataModule = module {
    single<ItemRepository> { ItemRepositoryImpl(get(), get()) }
    factory { GetItemsUseCase(get()) }
    viewModelOf(::ItemListViewModel)
}

// Hilt — アノテーションで注入
@HiltViewModel
class ItemListViewModel @Inject constructor(
    private val getItems: GetItemsUseCase
) : ViewModel()
```

## ViewModel パターン

単一の状態オブジェクト・イベントシンク・単方向データフロー:

```kotlin
data class ScreenState(
    val items: List<Item> = emptyList(),
    val isLoading: Boolean = false
)

class ScreenViewModel(private val useCase: GetItemsUseCase) : ViewModel() {
    private val _state = MutableStateFlow(ScreenState())
    val state = _state.asStateFlow()

    fun onEvent(event: ScreenEvent) {
        when (event) {
            is ScreenEvent.Load -> load()
            is ScreenEvent.Delete -> delete(event.id)
        }
    }
}
```

## Repository パターン

- `suspend` 関数は `Result<T>` またはカスタムエラー型を返す
- リアクティブストリームには `Flow` を使う
- ローカルデータソースとリモートデータソースを調整する

```kotlin
interface ItemRepository {
    suspend fun getById(id: String): Result<Item>
    suspend fun getAll(): Result<List<Item>>
    fun observeAll(): Flow<List<Item>>
}
```

> Repository の設計原則は `@rules/coding-ddd.md` の「Repository」セクションも参照すること。

## UseCase パターン

単一責任、`operator fun invoke` で呼び出す:

```kotlin
class GetItemUseCase(private val repository: ItemRepository) {
    suspend operator fun invoke(id: String): Result<Item> {
        return repository.getById(id)
    }
}

class GetItemsUseCase(private val repository: ItemRepository) {
    suspend operator fun invoke(): Result<List<Item>> {
        return repository.getAll()
    }
}
```

## expect/actual（KMP）

プラットフォーム固有の実装には expect/actual を使うこと:

```kotlin
// commonMain
expect fun platformName(): String
expect class SecureStorage {
    fun save(key: String, value: String)
    fun get(key: String): String?
}

// androidMain
actual fun platformName(): String = "Android"
actual class SecureStorage {
    actual fun save(key: String, value: String) { /* EncryptedSharedPreferences */ }
    actual fun get(key: String): String? = null /* ... */
}

// iosMain
actual fun platformName(): String = "iOS"
actual class SecureStorage {
    actual fun save(key: String, value: String) { /* Keychain */ }
    actual fun get(key: String): String? = null /* ... */
}
```

## コルーチンパターン

- ViewModel では `viewModelScope` を使い、構造化された子処理には `coroutineScope` を使う
- コールド Flow から StateFlow を作成するには `stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), initialValue)` を使う
- 子の失敗を独立させたい場合は `supervisorScope` を使う

## DSL を使った Builder パターン

```kotlin
class HttpClientConfig {
    var baseUrl: String = ""
    var timeout: Long = 30_000
    private val interceptors = mutableListOf<Interceptor>()

    fun interceptor(block: () -> Interceptor) {
        interceptors.add(block())
    }
}

fun httpClient(block: HttpClientConfig.() -> Unit): HttpClient {
    val config = HttpClientConfig().apply(block)
    return HttpClient(config)
}

// 使い方
val client = httpClient {
    baseUrl = "https://api.example.com"
    timeout = 15_000
    interceptor { AuthInterceptor(tokenProvider) }
}
```
