/// 活动模型
class ActivityModel {
  final String id;
  final String title; // 活动标题
  final String? imageUrl; // 活动封面图
  final String? description; // 活动描述
  final String? location; // 活动地点
  final double? latitude; // 纬度
  final double? longitude; // 经度
  final double? distance; // 距离（km）
  final int registrationStartTime; // 报名开始时间（时间戳）
  final int registrationEndTime; // 报名结束时间（时间戳）
  final int activityStartTime; // 活动开始时间（时间戳）
  final int activityEndTime; // 活动结束时间（时间戳）
  final String status; // 活动状态：registering（报名中）、registered（已报名）、ended（已结束）、full（已满员）
  final int maxParticipants; // 最大参与人数
  final int currentParticipants; // 当前参与人数
  final String? cityId; // 城市ID
  final String? cityName; // 城市名称

  ActivityModel({
    required this.id,
    required this.title,
    this.imageUrl,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.distance,
    required this.registrationStartTime,
    required this.registrationEndTime,
    required this.activityStartTime,
    required this.activityEndTime,
    this.status = 'registering',
    this.maxParticipants = 0,
    this.currentParticipants = 0,
    this.cityId,
    this.cityName,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'],
      description: json['description'],
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      distance: json['distance']?.toDouble(),
      registrationStartTime: json['registrationStartTime'] ?? 0,
      registrationEndTime: json['registrationEndTime'] ?? 0,
      activityStartTime: json['activityStartTime'] ?? 0,
      activityEndTime: json['activityEndTime'] ?? 0,
      status: json['status'] ?? 'registering',
      maxParticipants: json['maxParticipants'] ?? 0,
      currentParticipants: json['currentParticipants'] ?? 0,
      cityId: json['cityId'],
      cityName: json['cityName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'registrationStartTime': registrationStartTime,
      'registrationEndTime': registrationEndTime,
      'activityStartTime': activityStartTime,
      'activityEndTime': activityEndTime,
      'status': status,
      'maxParticipants': maxParticipants,
      'currentParticipants': currentParticipants,
      'cityId': cityId,
      'cityName': cityName,
    };
  }

  /// 获取报名状态文本
  String getStatusText() {
    switch (status) {
      case 'registering':
        return '报名中';
      case 'registered':
        return '已报名';
      case 'ended':
        return '已结束';
      case 'full':
        return '已满员';
      default:
        return '报名中';
    }
  }
}
