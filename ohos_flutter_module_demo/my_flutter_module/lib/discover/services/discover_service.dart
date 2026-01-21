import 'package:dio/dio.dart';
import '../models/tab_model.dart';
import '../config/app_config.dart';

/// 发现页面服务
class DiscoverService {
  final Dio _dio = Dio();

  DiscoverService() {
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// 获取Tab配置
  Future<List<TabModel>> getTabs() async {
    try {
      final response = await _dio.get('/api/discover/tabs');
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => TabModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      // 返回默认Tab列表
      return [
        TabModel(id: 'club', name: '俱乐部', visible: true, sort: 2),
        TabModel(id: 'smart-drive', name: '智驾', visible: true, sort: 3),
        TabModel(id: 'activity', name: '活动', visible: true, sort: 4),
        TabModel(id: 'news', name: '资讯', visible: true, sort: 5),
        TabModel(id: 'circle', name: '圈子', visible: true, sort: 6),
        TabModel(id: 'live', name: '直播', visible: true, sort: 7),
        TabModel(id: 'reputation', name: '口碑', visible: true, sort: 8),
      ];
    }
  }
}

