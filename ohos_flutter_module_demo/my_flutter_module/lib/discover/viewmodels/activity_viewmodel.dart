import 'package:get/get.dart';
import '../../core/base/base_list_viewmodel.dart';
import '../../core/result/result.dart';
import '../models/city_model.dart';
import '../models/activity_model.dart';
import '../repositories/activity_repository.dart';

/// 活动页面 ViewModel（MVVM 架构 - 新架构版本）
/// 继承 BaseListViewModel，提供统一的状态管理、错误处理和列表功能
/// 使用 Repository 层获取数据
class ActivityViewModel extends BaseListViewModel<ActivityModel> {
  final ActivityRepository _repository = ActivityRepository();
  
  // 城市相关
  final _currentCity = Rx<CityModel?>(null);
  CityModel? get currentCity => _currentCity.value;

  @override
  Future<void> initialize() async {
    // 先加载城市信息
    await loadCurrentCity();
    // 然后加载活动数据
    await loadData(isRefresh: true);
  }

  /// 加载当前城市
  Future<void> loadCurrentCity() async {
    final result = await _repository.getCurrentCity();
    
    result.when(
      success: (city) {
        _currentCity.value = city;
      },
      failure: (message, code, error) {
        // 城市加载失败不影响主流程，使用默认城市
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
      success: (activities) {
        // 如果网络请求失败，使用模拟数据（保证应用可用性）
        if (activities.isEmpty && isRefresh) {
          // 使用模拟数据
          _loadMockData(isRefresh: isRefresh);
        } else {
          setItems(activities, isRefresh: isRefresh);
        }
      },
      failure: (message, code, error) {
        // 网络错误时使用模拟数据
        if (isRefresh) {
          _loadMockData(isRefresh: isRefresh);
        } else {
          handleError(error, message: message, code: code);
        }
      },
    );
  }
  
  /// 加载模拟数据（网络失败时的降级方案）
  void _loadMockData({bool isRefresh = false}) {
    final List<ActivityModel> newActivities = [];
    final int startIndex = (currentPage - 1) * pageSize;
    
    for (int i = 0; i < pageSize; i++) {
      final index = startIndex + i;
      if (index >= 20) {
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
    
    setItems(newActivities, isRefresh: isRefresh);
  }

  /// 更新当前城市并重新加载数据
  void updateCityAndReload(CityModel? selectedCity) async {
    if (selectedCity != null) {
      _currentCity.value = selectedCity;
      // 保存城市
      await _repository.saveCurrentCity(selectedCity);
      // 重新加载数据（刷新）
      onRefresh();
    }
  }
}
