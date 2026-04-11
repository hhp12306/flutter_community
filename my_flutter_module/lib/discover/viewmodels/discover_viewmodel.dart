import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../core/base/base_viewmodel.dart';
import '../../core/result/result.dart';
import '../models/tab_model.dart';
import '../repositories/discover_repository.dart';

/// 发现页面 ViewModel（MVVM 架构 - 新架构版本）
/// 负责管理发现页面的状态和业务逻辑
/// 使用 Repository 层获取数据
class DiscoverViewModel extends BaseViewModel {
  final DiscoverRepository _repository = DiscoverRepository();
  
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

  /// 切到「活动」Tab 时递增，活动页 `ever` 监听后触发定位等逻辑
  final RxInt activityLocationTick = 0.obs;

  void notifyActivityTabSelected() {
    // 延后到微任务，避免 PageView 先触发 onPageChanged 再构建活动子页时，
    // ever 尚未注册而错过本次 tick 递增。
    scheduleMicrotask(() {
      final next = activityLocationTick.value + 1;
      activityLocationTick.value = next;
      print('=======>>>> [Discover] notifyActivityTabSelected -> activityLocationTick=$next');
    });
  }

  /// 加载Tab配置（供外部调用，不自动初始化）
  Future<void> loadTabs() async {
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

    // 从 Repository 获取Tab配置
    final result = await _repository.getTabs();
    
    result.when(
      success: (serverTabs) {
        // 合并Tab列表
        _allTabs.value = [...defaultTabs, ...serverTabs];
        
        // 按sort排序
        _allTabs.sort((a, b) => a.sort.compareTo(b.sort));
        
        // 过滤可见的Tab
        _visibleTabs.value = _allTabs.where((tab) => tab.visible).toList();
      },
      failure: (message, code, error) {
        // Repository 已经处理了错误，返回默认Tab列表
        // 这里直接使用默认配置
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
      },
    );
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
  /// 添加节流处理，避免过于频繁的更新
  void updateScrollOffset(double offset) {
    // 只在关键位置更新（每10px更新一次，减少更新频率）
    // 或者只在跨过44px阈值时更新
    final currentOffset = _scrollOffset.value;
    final threshold = 44.0;
    
    // 如果当前值和目标值在阈值两侧，或者差值超过10px，则更新
    if ((currentOffset <= threshold && offset > threshold) ||
        (currentOffset > threshold && offset <= threshold) ||
        (offset - currentOffset).abs() >= 10.0) {
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
