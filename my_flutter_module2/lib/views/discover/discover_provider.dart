import 'package:flutter/foundation.dart';
import '../../models/tab_model.dart';
import '../../services/discover_service.dart';

/// 发现页面状态管理
class DiscoverProvider extends ChangeNotifier {
  final DiscoverService _service = DiscoverService();
  
  List<TabModel> _allTabs = [];
  List<TabModel> _visibleTabs = [];
  int _currentIndex = 0;

  List<TabModel> get allTabs => _allTabs;
  List<TabModel> get visibleTabs => _visibleTabs;
  int get currentIndex => _currentIndex;

  /// 加载Tab配置
  Future<void> loadTabs() async {
    try {
      // 默认Tab列表（推荐、社区不支持配置，始终显示）
      final defaultTabs = [
        TabModel(
          id: 'recommend',
          name: '推荐',
          visible: true,
          sort: 0,
        ),
        TabModel(
          id: 'community',
          name: '社区',
          visible: true,
          sort: 1,
        ),
      ];

      // 从后端获取Tab配置
      final serverTabs = await _service.getTabs();
      
      // 合并Tab列表
      _allTabs = [...defaultTabs, ...serverTabs];
      
      // 按sort排序
      _allTabs.sort((a, b) => a.sort.compareTo(b.sort));
      
      // 过滤可见的Tab
      _visibleTabs = _allTabs.where((tab) => tab.visible).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('加载Tab配置失败: $e');
      // 如果加载失败，使用默认配置
      _allTabs = [
        TabModel(id: 'recommend', name: '推荐', visible: true, sort: 0),
        TabModel(id: 'community', name: '社区', visible: true, sort: 1),
        TabModel(id: 'club', name: '俱乐部', visible: true, sort: 2),
        TabModel(id: 'smart-drive', name: '智驾', visible: true, sort: 3),
        TabModel(id: 'activity', name: '活动', visible: true, sort: 4),
        TabModel(id: 'news', name: '资讯', visible: true, sort: 5),
        TabModel(id: 'circle', name: '圈子', visible: true, sort: 6),
        TabModel(id: 'live', name: '直播', visible: true, sort: 7),
        TabModel(id: 'reputation', name: '口碑', visible: true, sort: 8),
      ];
      _visibleTabs = _allTabs.where((tab) => tab.visible).toList();
      notifyListeners();
    }
  }

  /// 设置当前Tab索引
  void setCurrentIndex(int index) {
    if (_currentIndex != index && index >= 0 && index < _visibleTabs.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  /// 根据Tab ID获取索引
  int? getTabIndexById(String tabId) {
    for (int i = 0; i < _visibleTabs.length; i++) {
      if (_visibleTabs[i].id == tabId) {
        return i;
      }
    }
    return null;
  }

  /// 跳转到指定Tab
  void jumpToTab(String tabId) {
    final index = getTabIndexById(tabId);
    if (index != null) {
      setCurrentIndex(index);
    }
  }
}

