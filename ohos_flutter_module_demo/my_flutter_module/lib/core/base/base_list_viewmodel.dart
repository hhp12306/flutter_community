import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'base_viewmodel.dart';

/// 列表页面 ViewModel 基类
/// 提供分页、刷新等通用功能
abstract class BaseListViewModel<T> extends BaseViewModel {
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  
  // 分页相关
  final _currentPage = 1.obs;
  final _pageSize = 10.obs;
  final _hasMore = true.obs;
  final _items = <T>[].obs;

  // Getters
  int get currentPage => _currentPage.value;
  int get pageSize => _pageSize.value;
  bool get hasMore => _hasMore.value;
  List<T> get items => _items;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;

  /// 设置每页数量
  void setPageSize(int size) {
    _pageSize.value = size;
  }

  /// 下拉刷新
  Future<void> onRefresh() async {
    _currentPage.value = 1;
    _hasMore.value = true;
    
    await execute(() async {
      await loadData(isRefresh: true);
      refreshController.refreshCompleted();
    });
  }

  /// 上拉加载更多
  Future<void> onLoading() async {
    if (!_hasMore.value) {
      refreshController.loadNoData();
      return;
    }
    
    _currentPage.value++;
    
    await execute(() async {
      await loadMoreData();
      
      if (_hasMore.value) {
        refreshController.loadComplete();
      } else {
        refreshController.loadNoData();
      }
    }, showLoading: false);
  }

  /// 加载数据（刷新）
  /// 子类需要实现此方法
  Future<void> loadData({bool isRefresh = false}) async {
    // 子类实现
  }

  /// 加载更多数据
  /// 子类可以重写此方法，默认调用 loadData
  Future<void> loadMoreData() async {
    await loadData(isRefresh: false);
  }

  /// 设置数据
  void setItems(List<T> newItems, {bool isRefresh = false}) {
    if (isRefresh) {
      _items.value = newItems;
    } else {
      _items.addAll(newItems);
    }
    
    // 判断是否还有更多数据
    _hasMore.value = newItems.length >= _pageSize.value;
  }

  /// 添加单个数据
  void addItem(T item) {
    _items.add(item);
  }

  /// 移除数据
  void removeItem(T item) {
    _items.remove(item);
  }

  /// 清空数据
  void clearItems() {
    _items.clear();
    _currentPage.value = 1;
    _hasMore.value = true;
  }

  @override
  void reset() {
    super.reset();
    clearItems();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
