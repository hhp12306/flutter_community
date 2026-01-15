import 'package:get/get.dart';
import '../models/tab_model.dart';
import '../services/discover_service.dart';

/// 发现页面状态管理（GetX Controller）
class DiscoverController extends GetxController {
  final DiscoverService _service = DiscoverService();
  
  // 响应式变量
  final _allTabs = <TabModel>[].obs;
  final _visibleTabs = <TabModel>[].obs;
  final _currentIndex = 0.obs;
  final _scrollOffset = 0.0.obs;
  final _themeStyle = Rx<int?>(null);

  List<TabModel> get allTabs => _allTabs;
  List<TabModel> get visibleTabs => _visibleTabs;
  int get currentIndex => _currentIndex.value;
  double get scrollOffset => _scrollOffset.value;
  int? get themeStyle => _themeStyle.value;

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
      _allTabs.value = [...defaultTabs, ...serverTabs];
      
      // 按sort排序
      _allTabs.sort((a, b) => a.sort.compareTo(b.sort));
      
      // 过滤可见的Tab
      _visibleTabs.value = _allTabs.where((tab) => tab.visible).toList();
    } catch (e) {
      // 如果加载失败，使用默认配置
      _allTabs.value = [
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
      _visibleTabs.value = _allTabs.where((tab) => tab.visible).toList();
    }
  }

  /// 设置当前Tab索引
  void setCurrentIndex(int index) {
    if (_currentIndex.value != index && index >= 0 && index < _visibleTabs.length) {
      _currentIndex.value = index;
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

  /// 更新滚动偏移量
  void updateScrollOffset(double offset) {
    if (_scrollOffset.value != offset) {
      _scrollOffset.value = offset;
    }
  }

  /// 更新主题样式
  void updateThemeStyle(int? style) {
    if (_themeStyle.value != style) {
      _themeStyle.value = style;
    }
  }
}
