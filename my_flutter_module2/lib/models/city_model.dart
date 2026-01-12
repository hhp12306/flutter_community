/// 城市模型
class CityModel {
  final String id;
  final String name; // 城市名称
  final String? code; // 城市代码
  final String? province; // 省份
  final double? latitude; // 纬度
  final double? longitude; // 经度
  final bool isHot; // 是否热门城市

  CityModel({
    required this.id,
    required this.name,
    this.code,
    this.province,
    this.latitude,
    this.longitude,
    this.isHot = false,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'],
      province: json['province'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isHot: json['isHot'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'province': province,
      'latitude': latitude,
      'longitude': longitude,
      'isHot': isHot,
    };
  }
}

/// 定位信息模型
class LocationModel {
  final double latitude; // 纬度
  final double longitude; // 经度
  final String? cityName; // 城市名称
  final String? address; // 详细地址

  LocationModel({
    required this.latitude,
    required this.longitude,
    this.cityName,
    this.address,
  });
}
