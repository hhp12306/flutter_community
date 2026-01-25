import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/result/result.dart';
import '../models/tab_model.dart';

/// 发现页面服务
/// 纯网络请求层，返回 Result 类型
class DiscoverService {
  final Dio _dio = ApiClient.instance;

  /// 获取Tab配置
  Future<Result<List<TabModel>>> getTabs() async {
    try {
      final response = await _dio.get('/api/discover/tabs');
      if (response.statusCode == 200 && response.data['code'] == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final tabs = data.map((json) => TabModel.fromJson(json)).toList();
        return Success(tabs);
      }
      return Failure(
        message: '获取Tab配置失败',
        code: '${response.statusCode}',
      );
    } catch (e) {
      // 网络错误时返回默认Tab列表
      final defaultTabs = [
        TabModel(id: 'club', name: '俱乐部', visible: true, sort: 2),
        TabModel(id: 'smart-drive', name: '智驾', visible: true, sort: 3),
        TabModel(id: 'activity', name: '活动', visible: true, sort: 4),
        TabModel(id: 'news', name: '资讯', visible: true, sort: 5),
        TabModel(id: 'circle', name: '圈子', visible: true, sort: 6),
        TabModel(id: 'live', name: '直播', visible: true, sort: 7),
        TabModel(id: 'reputation', name: '口碑', visible: true, sort: 8),
      ];
      // 网络错误时返回默认值，但标记为失败（可选：也可以返回 Success）
      return Failure(
        message: '网络错误，使用默认配置',
        error: e,
      );
    }
  }
}

