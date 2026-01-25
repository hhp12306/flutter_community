import '../../core/repository/base_repository.dart';
import '../../core/result/result.dart';
import '../models/tab_model.dart';
import '../services/discover_service.dart';

/// 发现页面 Repository
/// 封装 Service 调用，处理数据转换和错误处理
class DiscoverRepository extends BaseRepository {
  final DiscoverService _service = DiscoverService();

  /// 获取Tab配置
  /// 如果网络请求失败，返回默认Tab列表
  Future<Result<List<TabModel>>> getTabs() async {
    final result = await _service.getTabs();
    
    // 如果网络失败，返回默认Tab列表（业务逻辑：保证应用可用性）
    return result.when(
      success: (tabs) => Success(tabs),
      failure: (message, code, error) {
        // 网络错误时返回默认Tab列表，保证应用可用
        final defaultTabs = [
          TabModel(id: 'club', name: '俱乐部', visible: true, sort: 2),
          TabModel(id: 'smart-drive', name: '智驾', visible: true, sort: 3),
          TabModel(id: 'activity', name: '活动', visible: true, sort: 4),
          TabModel(id: 'news', name: '资讯', visible: true, sort: 5),
          TabModel(id: 'circle', name: '圈子', visible: true, sort: 6),
          TabModel(id: 'live', name: '直播', visible: true, sort: 7),
          TabModel(id: 'reputation', name: '口碑', visible: true, sort: 8),
        ];
        return Success(defaultTabs);
      },
    );
  }
}
