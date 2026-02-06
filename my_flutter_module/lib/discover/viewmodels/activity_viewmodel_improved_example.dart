import 'package:get/get.dart';
import '../../core/base/base_list_viewmodel.dart';
import '../../core/result/result.dart';
import '../models/activity_model.dart';
import '../models/city_model.dart';
import '../services/location_service.dart';

/// 活动页面 ViewModel（改进版示例）
/// 使用 BaseListViewModel 基类，提供统一的状态管理和错误处理
class ActivityViewModelImproved extends BaseListViewModel<ActivityModel> {
  final LocationService _locationService = LocationService();
  
  // 城市相关
  final _currentCity = Rx<CityModel?>(null);
  CityModel? get currentCity => _currentCity.value;

  @override
  Future<void> initialize() async {
    await loadCurrentCity();
  }

  /// 加载当前城市
  Future<void> loadCurrentCity() async {
    await execute(() async {
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
      await loadData(isRefresh: true);
    });
  }

  @override
  Future<void> loadData({bool isRefresh = false}) async {
    // 使用 Result 类型处理结果（示例）
    // 实际项目中，Service 应该返回 Result 类型
    try {
      // TODO: 调用 Repository 或 Service
      // final result = await repository.getActivities(
      //   cityId: _currentCity.value?.id,
      //   page: currentPage,
      //   pageSize: pageSize,
      // );
      
      // result.when(
      //   success: (data) {
      //     setItems(data, isRefresh: isRefresh);
      //   },
      //   failure: (message, code, error) {
      //     handleError(error, message: message, code: code);
      //   },
      // );
      
      // 模拟数据（实际应该从 Repository 获取）
      await Future.delayed(const Duration(milliseconds: 500));
      
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
    } catch (e) {
      handleError(e, message: '加载活动数据失败');
    }
  }

  /// 更新当前城市并重新加载数据
  void updateCityAndReload(CityModel? selectedCity) {
    if (selectedCity != null) {
      _currentCity.value = selectedCity;
      // 重新加载数据（刷新）
      onRefresh();
    }
  }

  /// 重写错误处理（可选）
  @override
  void onError(ViewModelError error) {
    // 可以自定义错误处理逻辑
    super.onError(error);
    // 或者使用自定义的错误提示
    // Get.snackbar('活动加载失败', error.message);
  }
}
