import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/city_model.dart';

/// 定位服务
class LocationService {
  static const String _currentCityKey = 'current_city';
  static const String _currentCityNameKey = 'current_city_name';

  /// 获取当前位置
  /// 返回定位信息，如果定位失败返回null
  Future<LocationModel?> getCurrentLocation() async {
    try {
      // 检查定位权限
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // 定位服务未启用
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // 权限被拒绝
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // 权限被永久拒绝
        return null;
      }

      // 获取当前位置
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // TODO: 根据经纬度逆地理编码获取城市名称
      // 这里可以使用高德地图、百度地图等API进行逆地理编码
      // 暂时返回位置信息，城市名称需要从后端获取或使用第三方服务

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      // 定位失败
      return null;
    }
  }

  /// 保存当前选择的城市
  Future<void> saveCurrentCity(CityModel city) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentCityKey, city.id);
      await prefs.setString(_currentCityNameKey, city.name);
    } catch (e) {
      // 保存失败
    }
  }

  /// 获取保存的城市
  Future<CityModel?> getSavedCity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cityId = prefs.getString(_currentCityKey);
      final cityName = prefs.getString(_currentCityNameKey);

      if (cityId != null && cityName != null) {
        return CityModel(
          id: cityId,
          name: cityName,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 根据定位获取城市（模拟，实际应该调用后端API或第三方服务）
  Future<CityModel?> getCityByLocation(LocationModel location) async {
    // TODO: 调用后端API或第三方地图服务，根据经纬度获取城市信息
    // 这里返回模拟数据
    return CityModel(
      id: 'beijing',
      name: '北京',
      latitude: location.latitude,
      longitude: location.longitude,
    );
  }

  /// 获取热门城市列表（模拟，实际应该从后端获取）
  Future<List<CityModel>> getHotCities() async {
    // TODO: 从后端获取热门城市列表
    return [
      CityModel(id: 'beijing', name: '北京', isHot: true),
      CityModel(id: 'shanghai', name: '上海', isHot: true),
      CityModel(id: 'guangzhou', name: '广州', isHot: true),
      CityModel(id: 'shenzhen', name: '深圳', isHot: true),
      CityModel(id: 'hangzhou', name: '杭州', isHot: true),
      CityModel(id: 'chengdu', name: '成都', isHot: true),
    ];
  }

  /// 获取所有城市列表（模拟，实际应该从后端获取）
  Future<List<CityModel>> getAllCities() async {
    // TODO: 从后端获取所有城市列表
    // 这里返回模拟数据，包含热门城市和普通城市
    final hotCities = await getHotCities();
    
    final allCities = [
      ...hotCities,
      CityModel(id: 'nanjing', name: '南京'),
      CityModel(id: 'wuhan', name: '武汉'),
      CityModel(id: 'xian', name: '西安'),
      CityModel(id: 'tianjin', name: '天津'),
      CityModel(id: 'chongqing', name: '重庆'),
      CityModel(id: 'suzhou', name: '苏州'),
      CityModel(id: 'dalian', name: '大连'),
      CityModel(id: 'qingdao', name: '青岛'),
    ];
    
    return allCities;
  }

  /// 搜索城市
  Future<List<CityModel>> searchCities(String keyword) async {
    if (keyword.isEmpty) {
      return await getAllCities();
    }
    
    final allCities = await getAllCities();
    return allCities
        .where((city) => city.name.contains(keyword))
        .toList();
  }
}
