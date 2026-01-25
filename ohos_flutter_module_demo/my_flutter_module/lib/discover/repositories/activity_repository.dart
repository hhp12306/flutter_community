import '../../core/repository/base_repository.dart';
import '../../core/result/result.dart';
import '../models/activity_model.dart';
import '../models/city_model.dart';
import '../services/activity_service.dart';
import '../services/location_service.dart';

/// 活动 Repository
/// 封装 Service 调用，处理业务逻辑（城市选择、数据转换等）
class ActivityRepository extends BaseRepository {
  final ActivityService _activityService = ActivityService();
  final LocationService _locationService = LocationService();

  /// 获取活动列表
  Future<Result<List<ActivityModel>>> getActivities({
    String? cityId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final result = await _activityService.getActivities(
      cityId: cityId,
      page: page,
      pageSize: pageSize,
    );
    
    return result;
  }

  /// 获取当前城市
  Future<Result<CityModel?>> getCurrentCity() async {
    try {
      // 先尝试获取保存的城市
      final savedCity = await _locationService.getSavedCity();
      if (savedCity != null) {
        return Success(savedCity);
      }
      
      // 如果没有保存的城市，使用默认定位城市
      final locationCity = await _locationService.getLocationCity();
      return Success(locationCity);
    } catch (e) {
      return handleError(e, defaultMessage: '获取城市信息失败');
    }
  }

  /// 保存当前城市
  Future<Result<void>> saveCurrentCity(CityModel city) async {
    try {
      await _locationService.saveCurrentCity(city);
      return const Success(null);
    } catch (e) {
      return handleError(e, defaultMessage: '保存城市信息失败');
    }
  }
}
