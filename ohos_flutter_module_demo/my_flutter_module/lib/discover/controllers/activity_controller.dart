import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/city_model.dart';
import '../models/activity_model.dart';
import '../services/location_service.dart';

/// 活动页面 Controller（MVC 架构）
/// 负责处理用户输入，协调 Model 和 View
class ActivityController extends GetxController {
  final LocationService _locationService = LocationService();
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  
  // 响应式变量
  final _currentCity = Rx<CityModel?>(null);
  final _activities = <ActivityModel>[].obs;
  final _isLoading = true.obs;
  final _isInitialized = false.obs;
  final _currentPage = 1.obs;
  final _hasMore = true.obs;
  
  // Getters
  CityModel? get currentCity => _currentCity.value;
  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  int get currentPage => _currentPage.value;
  bool get hasMore => _hasMore.value;
  
  /// 初始化数据
  Future<void> init() async {
    if (_isInitialized.value) return;
    
    await loadCurrentCity();
    _isInitialized.value = true;
  }
  
  /// 加载当前城市
  Future<void> loadCurrentCity() async {
    _isLoading.value = true;
    
    try {
      // 先尝试获取保存的城市
      final savedCity = await _locationService.getSavedCity();
      
      if (savedCity != null) {
        _currentCity.value = savedCity;
      } else {
        // 如果没有保存的城市，使用默认定位城市
        final locationCity = await _locationService.getLocationCity();
        if (locationCity != null) {
          await _locationService.saveCurrentCity(locationCity);
          _currentCity.value = locationCity;
        }
      }
      
      // 加载活动数据
      await loadActivityData();
    } catch (e) {
      Get.snackbar('错误', '加载城市信息失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 更新当前城市并重新加载数据
  void updateCityAndReload(CityModel? selectedCity) {
    if (selectedCity != null) {
      _currentCity.value = selectedCity;
      // 重新加载数据（刷新）
      _currentPage.value = 1;
      _hasMore.value = true;
      loadActivityData(isRefresh: true);
    }
  }
  
  /// 下拉刷新
  Future<void> onRefresh() async {
    _currentPage.value = 1;
    _hasMore.value = true;
    await loadActivityData(isRefresh: true);
    refreshController.refreshCompleted();
  }
  
  /// 上拉加载更多
  Future<void> onLoading() async {
    if (!_hasMore.value) {
      refreshController.loadNoData();
      return;
    }
    
    _currentPage.value++;
    await loadActivityData(isRefresh: false);
    
    if (_hasMore.value) {
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }
  
  /// 加载活动数据（根据当前城市）
  /// [isRefresh] 是否为刷新操作（true：刷新，false：加载更多）
  Future<void> loadActivityData({bool isRefresh = false}) async {
    try {
      // TODO: 根据当前城市加载活动数据
      // 这里使用模拟数据
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 模拟分页数据
      final List<ActivityModel> newActivities = [];
      final int pageSize = 10; // 每页数量
      final int startIndex = (_currentPage.value - 1) * pageSize;
      
      // 生成模拟数据（实际应该从后端获取）
      for (int i = 0; i < pageSize; i++) {
        final index = startIndex + i;
        if (index >= 20) {
          // 模拟只有20条数据
          _hasMore.value = false;
          break;
        }
        
        newActivities.add(
          ActivityModel(
            id: '${index + 1}',
            title: '测试活动 ${index + 1}',
            imageUrl: 'https://img.bydauto.com.cn/bydauto/bydauto-cms/2024/07/01/1719806400000.jpg',
            location: '广东深圳深圳坪山',
            distance: 5.6 + (index * 0.5),
            registrationStartTime: DateTime(2026, 1, 5).millisecondsSinceEpoch,
            registrationEndTime: DateTime(2026, 1, 31).millisecondsSinceEpoch,
            activityStartTime: DateTime(2026, 2, 1).millisecondsSinceEpoch,
            activityEndTime: DateTime(2026, 2, 5).millisecondsSinceEpoch,
            status: index % 3 == 0 ? 'registering' : (index % 3 == 1 ? 'registered' : 'ended'),
            cityId: _currentCity.value?.id,
            cityName: _currentCity.value?.name,
          ),
        );
      }
      
      if (isRefresh) {
        // 刷新：替换所有数据
        _activities.value = newActivities;
      } else {
        // 加载更多：追加数据
        _activities.addAll(newActivities);
      }
    } catch (e) {
      Get.snackbar('错误', '加载活动数据失败: $e');
    }
  }
  
  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
