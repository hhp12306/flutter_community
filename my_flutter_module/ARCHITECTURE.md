# Flutter MVVM 架构设计文档

## 📐 架构概览

本项目采用**改进的 MVVM（Model-View-ViewModel）架构模式**，结合 **Repository 模式**和 **Result 类型**，提供统一的状态管理、错误处理和类型安全的数据流。

### 架构层次

```
┌─────────────────────────────────────────────────────────┐
│                        View 层                           │
│  (UI组件、页面、Widget)                                    │
└────────────────────┬────────────────────────────────────┘
                     │ 绑定
                     ↓
┌─────────────────────────────────────────────────────────┐
│                     ViewModel 层                         │
│  (业务逻辑、状态管理、用户交互处理)                          │
│  - BaseViewModel / BaseListViewModel                     │
└────────────────────┬────────────────────────────────────┘
                     │ 调用
                     ↓
┌─────────────────────────────────────────────────────────┐
│                    Repository 层                        │
│  (数据转换、业务逻辑、缓存、降级方案)                       │
│  - BaseRepository                                        │
└────────────────────┬────────────────────────────────────┘
                     │ 调用
                     ↓
┌─────────────────────────────────────────────────────────┐
│                      Service 层                          │
│  (纯网络请求、数据序列化/反序列化)                          │
│  - 返回 Result<T> 类型                                    │
└────────────────────┬────────────────────────────────────┘
                     │ 使用
                     ↓
┌─────────────────────────────────────────────────────────┐
│                    Network 层                            │
│  (统一网络客户端、拦截器、配置)                             │
│  - ApiClient (单例 Dio)                                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│                      Model 层                            │
│  (数据模型、序列化逻辑)                                    │
└─────────────────────────────────────────────────────────┘
```

---

## 📁 项目目录结构

```
lib/
├── core/                           # 核心基础层
│   ├── base/                      # 基类
│   │   ├── base_viewmodel.dart    # ViewModel 基类
│   │   └── base_list_viewmodel.dart # 列表 ViewModel 基类
│   ├── network/                   # 网络层
│   │   └── api_client.dart        # 统一网络客户端
│   ├── repository/                # Repository 基类
│   │   └── base_repository.dart   # Repository 基类
│   └── result/                    # 结果类型
│       └── result.dart            # Result<T> 类型
│
├── discover/                      # 业务模块
│   ├── models/                    # 数据模型层
│   │   ├── activity_model.dart
│   │   ├── article_model.dart
│   │   └── ...
│   │
│   ├── services/                  # 服务层（纯网络请求）
│   │   ├── activity_service.dart
│   │   ├── discover_service.dart
│   │   └── ...
│   │
│   ├── repositories/              # Repository 层（数据仓库）
│   │   ├── activity_repository.dart
│   │   ├── discover_repository.dart
│   │   └── ...
│   │
│   ├── viewmodels/                # 视图模型层
│   │   ├── activity_viewmodel.dart
│   │   ├── discover_viewmodel.dart
│   │   └── ...
│   │
│   └── views/                     # 视图层
│       ├── discover/
│       │   ├── discover_page.dart
│       │   └── pages/
│       └── ...
│
└── main.dart                      # 应用入口
```

---

## 🏗️ 各层详细说明

### 1. Model 层（数据模型）

**职责**:
- 定义数据结构
- 数据序列化/反序列化（`fromJson` / `toJson`）
- 数据验证（可选）

**位置**: `lib/discover/models/`

**示例**:
```dart
class ActivityModel {
  final String id;
  final String title;
  // ... 其他字段

  ActivityModel({
    required this.id,
    required this.title,
    // ...
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      // ...
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      // ...
    };
  }
}
```

**特点**:
- ✅ 使用不可变对象（final 字段）
- ✅ 包含序列化方法
- ✅ 类型安全

---

### 2. Network 层（网络层）

**职责**:
- 统一网络配置
- 单例 Dio 实例
- 统一拦截器（日志、认证、错误处理）

**位置**: `lib/core/network/api_client.dart`

**实现**:
```dart
class ApiClient {
  static Dio? _dio;
  
  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }
  
  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
    
    // 添加拦截器
    dio.interceptors.add(LogInterceptor());
    // dio.interceptors.add(AuthInterceptor());
    // dio.interceptors.add(ErrorInterceptor());
    
    return dio;
  }
}
```

**特点**:
- ✅ 单例模式
- ✅ 统一配置
- ✅ 便于扩展拦截器

---

### 3. Service 层（服务层）

**职责**:
- 纯网络请求
- 数据序列化/反序列化
- 返回 `Result<T>` 类型

**位置**: `lib/discover/services/`

**实现**:
```dart
class ActivityService {
  final Dio _dio = ApiClient.instance;

  /// 获取活动列表
  Future<Result<List<ActivityModel>>> getActivities({
    String? cityId,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/api/activities',
        queryParameters: {
          if (cityId != null) 'cityId': cityId,
          'page': page,
          'pageSize': pageSize,
        },
      );
      
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final activities = data
            .map((json) => ActivityModel.fromJson(json))
            .toList();
        return Success(activities);
      }
      
      return Failure(
        message: '获取活动列表失败',
        code: '${response.statusCode}',
      );
    } catch (e) {
      return _handleError(e, '获取活动列表失败');
    }
  }
  
  /// 处理错误
  Result<T> _handleError<T>(dynamic error, String defaultMessage) {
    String message = defaultMessage;
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = '网络超时，请检查网络连接';
          break;
        case DioExceptionType.badResponse:
          message = '服务器错误: ${error.response?.statusCode}';
          break;
        default:
          message = '网络错误，请稍后重试';
      }
    }
    
    return Failure<T>(
      message: message,
      error: error,
    );
  }
}
```

**特点**:
- ✅ 返回 `Result<T>` 类型
- ✅ 统一的错误处理
- ✅ 使用统一的 ApiClient

---

### 4. Repository 层（数据仓库层）

**职责**:
- 封装 Service 调用
- 数据转换和业务逻辑
- 缓存管理（可选）
- 降级方案（网络失败时的处理）

**位置**: `lib/discover/repositories/`

**实现**:
```dart
class ActivityRepository extends BaseRepository {
  final ActivityService _activityService = ActivityService();
  final LocationService _locationService = LocationService();

  /// 获取活动列表
  Future<Result<List<ActivityModel>>> getActivities({
    String? cityId,
    int page = 1,
    int pageSize = 10,
  }) async {
    return await _activityService.getActivities(
      cityId: cityId,
      page: page,
      pageSize: pageSize,
    );
  }

  /// 获取当前城市
  Future<Result<CityModel?>> getCurrentCity() async {
    try {
      final savedCity = await _locationService.getSavedCity();
      if (savedCity != null) {
        return Success(savedCity);
      }
      
      final locationCity = await _locationService.getLocationCity();
      return Success(locationCity);
    } catch (e) {
      return handleError(e, defaultMessage: '获取城市信息失败');
    }
  }
}
```

**特点**:
- ✅ 封装多个 Service 调用
- ✅ 处理业务逻辑
- ✅ 可以添加缓存
- ✅ 提供降级方案

---

### 5. ViewModel 层（视图模型层）

**职责**:
- 业务逻辑处理
- 状态管理
- 用户交互处理
- 数据绑定

**位置**: `lib/discover/viewmodels/`

#### 5.1 BaseViewModel（基础 ViewModel）

**功能**:
- 统一的状态管理（idle, loading, success, error）
- 统一的错误处理
- 生命周期管理
- 初始化流程

**实现**:
```dart
abstract class BaseViewModel extends GetxController {
  final _status = ViewModelStatus.idle.obs;
  final _error = Rx<ViewModelError?>(null);
  final _isInitialized = false.obs;

  ViewModelStatus get status => _status.value;
  bool get isLoading => _status.value == ViewModelStatus.loading;
  bool get isError => _status.value == ViewModelStatus.error;
  ViewModelError? get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> initialize() async {
    // 子类实现
  }

  Future<T?> execute<T>(
    Future<T> Function() action, {
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        setStatus(ViewModelStatus.loading);
      }
      final result = await action();
      if (showLoading) {
        setStatus(ViewModelStatus.success);
      }
      return result;
    } catch (e) {
      handleError(e);
      return null;
    }
  }
}
```

#### 5.2 BaseListViewModel（列表 ViewModel）

**功能**:
- 继承 BaseViewModel
- 分页管理
- 下拉刷新/上拉加载
- 列表数据管理

**实现**:
```dart
abstract class BaseListViewModel<T> extends BaseViewModel {
  final RefreshController refreshController = RefreshController();
  final _items = <T>[].obs;
  final _currentPage = 1.obs;
  final _hasMore = true.obs;

  List<T> get items => _items;
  int get currentPage => _currentPage.value;
  bool get hasMore => _hasMore.value;

  Future<void> onRefresh() async {
    _currentPage.value = 1;
    _hasMore.value = true;
    await execute(() async {
      await loadData(isRefresh: true);
      refreshController.refreshCompleted();
    });
  }

  Future<void> loadData({bool isRefresh = false}) async {
    // 子类实现
  }

  void setItems(List<T> newItems, {bool isRefresh = false}) {
    if (isRefresh) {
      _items.value = newItems;
    } else {
      _items.addAll(newItems);
    }
    _hasMore.value = newItems.length >= pageSize;
  }
}
```

#### 5.3 具体 ViewModel 示例

```dart
class ActivityViewModel extends BaseListViewModel<ActivityModel> {
  final ActivityRepository _repository = ActivityRepository();
  final _currentCity = Rx<CityModel?>(null);
  
  CityModel? get currentCity => _currentCity.value;

  @override
  Future<void> initialize() async {
    await loadCurrentCity();
    await loadData(isRefresh: true);
  }

  Future<void> loadCurrentCity() async {
    final result = await _repository.getCurrentCity();
    result.when(
      success: (city) => _currentCity.value = city,
      failure: (message, code, error) {
        handleError(error, message: message, code: code);
      },
    );
  }

  @override
  Future<void> loadData({bool isRefresh = false}) async {
    final result = await _repository.getActivities(
      cityId: _currentCity.value?.id,
      page: currentPage,
      pageSize: pageSize,
    );
    
    result.when(
      success: (data) {
        if (data.isEmpty && isRefresh) {
          _loadMockData(isRefresh: isRefresh);
        } else {
          setItems(data, isRefresh: isRefresh);
        }
      },
      failure: (message, code, error) {
        if (isRefresh) {
          _loadMockData(isRefresh: isRefresh);
        } else {
          handleError(error, message: message, code: code);
        }
      },
    );
  }
}
```

**特点**:
- ✅ 继承基类，获得通用功能
- ✅ 使用 Repository 获取数据
- ✅ 使用 Result 类型处理结果
- ✅ 统一的错误处理

---

### 6. View 层（视图层）

**职责**:
- UI 展示
- 用户交互
- 绑定 ViewModel 数据

**位置**: `lib/discover/views/`

**实现**:
```dart
class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with AutomaticKeepAliveClientMixin {
  late final ActivityViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Get.put(ActivityViewModel());
    // BaseViewModel 会在 onInit 时自动调用 initialize()
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Obx(() => Scaffold(
      body: _viewModel.isLoading && _viewModel.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // UI 组件
                Expanded(
                  child: SmartRefresher(
                    controller: _viewModel.refreshController,
                    onRefresh: () => _viewModel.onRefresh(),
                    onLoading: () => _viewModel.onLoading(),
                    child: _viewModel.items.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _viewModel.items.length,
                            itemBuilder: (context, index) {
                              return _buildItem(_viewModel.items[index]);
                            },
                          ),
                  ),
                ),
              ],
            ),
    ));
  }
}
```

**特点**:
- ✅ UI 代码简洁
- ✅ 使用 `Obx` 响应式更新
- ✅ 使用基类提供的状态（`isLoading`, `isError` 等）

---

## 🔄 数据流向

### 完整数据流

```
1. 用户操作
   ↓
2. View 触发事件
   ↓
3. ViewModel 处理业务逻辑
   ↓
4. ViewModel 调用 Repository
   ↓
5. Repository 调用 Service
   ↓
6. Service 使用 ApiClient 发起网络请求
   ↓
7. 网络返回数据
   ↓
8. Service 解析数据，返回 Result<T>
   ↓
9. Repository 处理业务逻辑，返回 Result<T>
   ↓
10. ViewModel 使用 result.when() 处理结果
    ↓
11. ViewModel 更新状态（通过 .obs）
    ↓
12. View 自动更新（通过 Obx）
```

### Result 类型使用流程

```dart
// Service 层
Future<Result<List<ActivityModel>>> getActivities() async {
  try {
    // 网络请求
    return Success(data);
  } catch (e) {
    return Failure(message: '加载失败', error: e);
  }
}

// Repository 层
Future<Result<List<ActivityModel>>> getActivities() async {
  return await _service.getActivities();
}

// ViewModel 层
final result = await _repository.getActivities();
result.when(
  success: (data) {
    setItems(data, isRefresh: isRefresh);
  },
  failure: (message, code, error) {
    handleError(error, message: message, code: code);
  },
);
```

---

## 🎯 核心组件说明

### 1. Result<T> 类型

**位置**: `lib/core/result/result.dart`

**功能**:
- 类型安全的结果处理
- 避免使用 try-catch
- 函数式编程风格

**使用方式**:
```dart
// 方式1: when 方法（推荐）
result.when(
  success: (data) => print('成功: $data'),
  failure: (msg, code, err) => print('失败: $msg'),
);

// 方式2: 链式调用
result
  .onSuccess((data) => print('成功: $data'))
  .onFailure((msg, code, err) => print('失败: $msg'));

// 方式3: 属性访问
if (result.isSuccess) {
  final data = result.dataOrNull;
}
```

### 2. BaseViewModel

**位置**: `lib/core/base/base_viewmodel.dart`

**提供功能**:
- 状态管理（idle, loading, success, error）
- 错误处理
- 生命周期管理
- `execute()` 方法统一处理异步操作

### 3. BaseListViewModel

**位置**: `lib/core/base/base_list_viewmodel.dart`

**提供功能**:
- 继承 BaseViewModel 的所有功能
- 分页管理
- 下拉刷新/上拉加载
- 列表数据管理

### 4. BaseRepository

**位置**: `lib/core/repository/base_repository.dart`

**提供功能**:
- 统一的错误处理方法
- 处理 DioException 类型错误

### 5. ApiClient

**位置**: `lib/core/network/api_client.dart`

**提供功能**:
- 单例 Dio 实例
- 统一配置
- 统一拦截器

---

## 📋 开发规范

### 1. ViewModel 开发规范

```dart
// ✅ 正确：继承基类
class MyViewModel extends BaseViewModel {
  final MyRepository _repository = MyRepository();
  
  @override
  Future<void> initialize() async {
    await loadData();
  }
  
  Future<void> loadData() async {
    final result = await _repository.getData();
    result.when(
      success: (data) {
        // 处理成功
      },
      failure: (message, code, error) {
        handleError(error, message: message);
      },
    );
  }
}

// ❌ 错误：直接继承 GetxController
class MyViewModel extends GetxController {
  // 缺少统一的状态管理和错误处理
}
```

### 2. Service 开发规范

```dart
// ✅ 正确：返回 Result 类型
class MyService {
  final Dio _dio = ApiClient.instance;
  
  Future<Result<List<MyModel>>> getData() async {
    try {
      // 网络请求
      return Success(data);
    } catch (e) {
      return Failure(message: '加载失败', error: e);
    }
  }
}

// ❌ 错误：直接返回数据或抛出异常
class MyService {
  Future<List<MyModel>> getData() async {
    // 直接返回，错误处理不统一
    return data;
  }
}
```

### 3. Repository 开发规范

```dart
// ✅ 正确：封装 Service，处理业务逻辑
class MyRepository extends BaseRepository {
  final MyService _service = MyService();
  
  Future<Result<List<MyModel>>> getData() async {
    final result = await _service.getData();
    // 可以在这里添加缓存、数据转换等逻辑
    return result;
  }
}

// ❌ 错误：ViewModel 直接使用 Service
class MyViewModel extends BaseViewModel {
  final MyService _service = MyService(); // 不应该直接使用
}
```

### 4. View 开发规范

```dart
// ✅ 正确：使用 Obx 响应式更新，使用基类状态
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late final MyViewModel _viewModel;
  
  @override
  void initState() {
    super.initState();
    _viewModel = Get.put(MyViewModel());
  }
  
  @override
  Widget build(BuildContext context) {
    return Obx(() => Scaffold(
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(...),
    ));
  }
}
```

---

## 🔧 最佳实践

### 1. 错误处理

**统一使用 Result 类型**:
```dart
// Service 层
Future<Result<T>> getData() async {
  try {
    return Success(data);
  } catch (e) {
    return Failure(message: '错误信息', error: e);
  }
}

// ViewModel 层
final result = await _repository.getData();
result.when(
  success: (data) => _handleSuccess(data),
  failure: (msg, code, err) => handleError(err, message: msg),
);
```

### 2. 状态管理

**使用基类提供的状态**:
```dart
// ✅ 正确
if (_viewModel.isLoading) { ... }
if (_viewModel.isError) { ... }
if (_viewModel.isSuccess) { ... }

// ❌ 错误：不要自己定义状态
final _isLoading = false.obs; // 基类已提供
```

### 3. 列表管理

**使用 BaseListViewModel**:
```dart
// ✅ 正确
class MyListViewModel extends BaseListViewModel<ItemModel> {
  @override
  Future<void> loadData({bool isRefresh = false}) async {
    final result = await _repository.getItems();
    result.when(
      success: (data) => setItems(data, isRefresh: isRefresh),
      failure: (msg, code, err) => handleError(err, message: msg),
    );
  }
}
```

### 4. 降级方案

**网络失败时提供降级数据**:
```dart
result.when(
  success: (data) {
    if (data.isEmpty && isRefresh) {
      _loadMockData(); // 使用模拟数据
    } else {
      setItems(data);
    }
  },
  failure: (message, code, error) {
    if (isRefresh) {
      _loadMockData(); // 网络失败时使用模拟数据
    }
  },
);
```

---

## 📊 架构优势

### 1. 解耦性 ⭐⭐⭐⭐⭐
- ViewModel 不直接依赖 Service
- Repository 可以轻松切换数据源
- 便于测试和 Mock

### 2. 类型安全 ⭐⭐⭐⭐⭐
- 使用 Result 类型，避免空指针
- 编译时类型检查
- 函数式编程风格

### 3. 统一性 ⭐⭐⭐⭐⭐
- 统一的状态管理
- 统一的错误处理
- 统一的网络配置

### 4. 可维护性 ⭐⭐⭐⭐⭐
- 清晰的职责分离
- 代码复用率高
- 易于扩展

### 5. 可测试性 ⭐⭐⭐⭐⭐
- Repository 可以轻松 Mock
- Result 类型便于测试各种场景
- 依赖注入支持

---

## 🚀 扩展指南

### 添加新的功能模块

1. **创建 Model**
   ```dart
   // lib/discover/models/new_model.dart
   class NewModel {
     // ...
   }
   ```

2. **创建 Service**
   ```dart
   // lib/discover/services/new_service.dart
   class NewService {
     final Dio _dio = ApiClient.instance;
     
     Future<Result<List<NewModel>>> getData() async {
       // ...
     }
   }
   ```

3. **创建 Repository**
   ```dart
   // lib/discover/repositories/new_repository.dart
   class NewRepository extends BaseRepository {
     final NewService _service = NewService();
     
     Future<Result<List<NewModel>>> getData() async {
       return await _service.getData();
     }
   }
   ```

4. **创建 ViewModel**
   ```dart
   // lib/discover/viewmodels/new_viewmodel.dart
   class NewViewModel extends BaseListViewModel<NewModel> {
     final NewRepository _repository = NewRepository();
     
     @override
     Future<void> loadData({bool isRefresh = false}) async {
       final result = await _repository.getData();
       result.when(
         success: (data) => setItems(data, isRefresh: isRefresh),
         failure: (msg, code, err) => handleError(err, message: msg),
       );
     }
   }
   ```

5. **创建 View**
   ```dart
   // lib/discover/views/new_page.dart
   class NewPage extends StatefulWidget {
     // ...
   }
   ```

---

## 📚 相关文档

- `MVVM_ARCHITECTURE_ANALYSIS.md` - 架构分析报告
- `MVVM_IMPROVEMENT_GUIDE.md` - 改进指南
- `MIGRATION_SUMMARY.md` - 迁移总结
- `REPOSITORY_MIGRATION_SUMMARY.md` - Repository 层迁移总结
- `MVVM_OPTIMIZATION_ANALYSIS.md` - 优化分析

---

## 🎯 总结

本架构提供了：

1. ✅ **清晰的层次结构** - Model、Service、Repository、ViewModel、View
2. ✅ **统一的基类** - BaseViewModel、BaseListViewModel、BaseRepository
3. ✅ **类型安全** - Result 类型、强类型 Model
4. ✅ **统一错误处理** - 通过 Result 类型和基类方法
5. ✅ **易于测试** - Repository 模式便于 Mock
6. ✅ **易于维护** - 代码复用、职责清晰
7. ✅ **统一网络层** - ApiClient 单例

这是一个**生产级别的 MVVM 架构**，适合中大型 Flutter 项目使用。
