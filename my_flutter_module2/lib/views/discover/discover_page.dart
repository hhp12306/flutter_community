import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'discover_provider.dart';
import 'components/discover_tab_bar.dart';
import 'components/discover_app_bar.dart';
import 'pages/recommend_page.dart';
import 'pages/community_page.dart';
import 'pages/club_page.dart';
import 'pages/smart_drive_page.dart';
import 'pages/activity_page.dart';
import 'pages/news_page.dart';
import 'pages/circle_page.dart';
import 'pages/live_page.dart';
import 'pages/reputation_page.dart';
import '../../models/tab_model.dart';

/// 发现页面（主页面）
/// 包含顶部Tab栏和各个Tab页面内容
class DiscoverPage extends StatefulWidget {
  final int? initialIndex; // 初始Tab索引，支持路由跳转
  final String? initialTabId; // 初始Tab ID

  const DiscoverPage({
    Key? key,
    this.initialIndex,
    this.initialTabId,
  }) : super(key: key);

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  PageController? _pageController;
  final DiscoverProvider _provider = DiscoverProvider();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  /// 初始化Tab和Page控制器
  Future<void> _initialize() async {
    // 初始化Tab列表
    await _provider.loadTabs();
    
    if (!mounted) return;
    
    // 计算初始索引
    int initialIndex = widget.initialIndex ?? 0;
    if (widget.initialTabId != null) {
      final index = _provider.getTabIndexById(widget.initialTabId!);
      if (index != null) {
        initialIndex = index;
      }
    }

    // 创建Tab控制器和Page控制器
    _tabController = TabController(
      length: _provider.visibleTabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
    
    _pageController = PageController(initialPage: initialIndex);

    // Tab切换监听
    _tabController!.addListener(() {
      if (!_tabController!.indexIsChanging && _pageController != null) {
        _pageController!.animateToPage(
          _tabController!.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  /// 构建各个Tab页面
  Widget _buildPageByTab(TabModel tab) {
    switch (tab.id) {
      case 'recommend':
        return const RecommendPage();
      case 'community':
        return const CommunityPage();
      case 'club':
        return const ClubPage();
      case 'smart-drive':
        return const SmartDrivePage();
      case 'activity':
        return const ActivityPage();
      case 'news':
        return const NewsPage();
      case 'circle':
        return const CirclePage();
      case 'live':
        return const LivePage();
      case 'reputation':
        return const ReputationPage();
      default:
        return const RecommendPage();
    }
  }

  /// 处理页面滑动切换
  void _onPageChanged(int index) {
    if (_tabController != null && _tabController!.index != index) {
      _tabController!.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _tabController == null || _pageController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: DiscoverAppBar(
          onSearchTap: () {
            // 跳转搜索页面
          },
          onMessageTap: () {
            // 跳转消息中心
          },
          child: Consumer<DiscoverProvider>(
            builder: (context, provider, child) {
              if (provider.visibleTabs.isEmpty) {
                return const SizedBox.shrink();
              }
              // 如果Tab数量变化，需要重新创建控制器
              if (provider.visibleTabs.length != _tabController!.length) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _tabController?.dispose();
                  _pageController?.dispose();
                  _tabController = TabController(
                    length: provider.visibleTabs.length,
                    vsync: this,
                  );
                  _pageController = PageController();
                  setState(() {});
                });
              }
              return DiscoverTabBar(
                tabs: provider.visibleTabs,
                controller: _tabController!,
                onTabTap: (index) {
                  _pageController?.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              );
            },
          ),
        ),
        body: Consumer<DiscoverProvider>(
          builder: (context, provider, child) {
            if (provider.visibleTabs.isEmpty || _pageController == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return PageView.builder(
              controller: _pageController!,
              onPageChanged: _onPageChanged,
              itemCount: provider.visibleTabs.length,
              itemBuilder: (context, index) {
                final tab = provider.visibleTabs[index];
                return _buildPageByTab(tab);
              },
            );
          },
        ),
      ),
    );
  }
}

