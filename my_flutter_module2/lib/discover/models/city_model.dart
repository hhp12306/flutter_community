/// 城市模型
class CityModel {
  final String id;
  final String name; // 城市名称
  final String? code; // 城市代码
  final String? province; // 省份
  final double? latitude; // 纬度
  final double? longitude; // 经度
  final bool isHot; // 是否热门城市
  final String? initialLetter; // 拼音首字母（用于分组和索引）

  CityModel({
    required this.id,
    required this.name,
    this.code,
    this.province,
    this.latitude,
    this.longitude,
    this.isHot = false,
    this.initialLetter,
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
      initialLetter: json['initialLetter'],
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
      'initialLetter': initialLetter,
    };
  }

  /// 获取城市名称的首字母（用于分组）
  /// 如果是中文，返回拼音首字母；如果是英文，返回首字母
  String getInitialLetter() {
    if (initialLetter != null && initialLetter!.isNotEmpty) {
      return initialLetter!.toUpperCase();
    }
    
    // 如果没有提供首字母，尝试从名称中提取
    if (name.isEmpty) return '#';
    
    // 如果是中文，使用简单的映射（实际应该使用拼音库）
    // 这里使用城市名称的第一个字符的拼音首字母映射
    final firstChar = name[0];
    
    // 简单的拼音首字母映射（常用城市）
    final pinyinMap = {
      '北': 'B', '上': 'S', '广': 'G', '深': 'S', '杭': 'H', '成': 'C',
      '南': 'N', '武': 'W', '西': 'X', '天': 'T', '重': 'C', '苏': 'S',
      '大': 'D', '青': 'Q', '长': 'C', '沈': 'S', '郑': 'Z', '济': 'J',
      '哈': 'H', '福': 'F', '厦': 'X', '合': 'H', '石': 'S', '太': 'T',
    };
    
    if (pinyinMap.containsKey(firstChar)) {
      return pinyinMap[firstChar]!;
    }
    
    // 如果是英文字母，直接返回大写
    if (firstChar.codeUnitAt(0) >= 65 && firstChar.codeUnitAt(0) <= 90) {
      return firstChar.toUpperCase();
    }
    if (firstChar.codeUnitAt(0) >= 97 && firstChar.codeUnitAt(0) <= 122) {
      return firstChar.toUpperCase();
    }
    
    // 其他情况返回 #
    return '#';
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
