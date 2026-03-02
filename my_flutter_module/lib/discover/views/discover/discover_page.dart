import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../viewmodels/discover_viewmodel.dart';
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
import '../../utils/route_guard.dart';

/// 发现页面（主页面）
/// 状态由 GetX ViewModel 驱动，严格 MVVM：View 仅通过 Obx 观察 ViewModel
class DiscoverPage extends StatefulWidget {
  final int? initialIndex;
  final String? initialTabId;

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
  late final DiscoverViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = Get.put(DiscoverViewModel(), tag: 'discover');
    _viewModel.loadTabs();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_viewModel.visibleTabs.isEmpty) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return _DiscoverPageBody(
        viewModel: _viewModel,
        initialIndex: widget.initialIndex,
        initialTabId: widget.initialTabId,
        vsync: this,
      );
    });
  }
}

/// 内容区：Tab/Page 控制器在此创建，仅依赖 ViewModel 的 visibleTabs
class _DiscoverPageBody extends StatefulWidget {
  final DiscoverViewModel viewModel;
  final int? initialIndex;
  final String? initialTabId;
  final TickerProvider vsync;

  const _DiscoverPageBody({
    required this.viewModel,
    required this.initialIndex,
    required this.initialTabId,
    required this.vsync,
  });

  @override
  State<_DiscoverPageBody> createState() => _DiscoverPageBodyState();
}

class _DiscoverPageBodyState extends State<_DiscoverPageBody> {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    int initialIndex = widget.initialIndex ?? 0;
    if (widget.initialTabId != null) {
      final index = widget.viewModel.getTabIndexById(widget.initialTabId!);
      if (index != null) initialIndex = index;
    }
    _tabController = TabController(
      length: widget.viewModel.visibleTabs.length,
      vsync: widget.vsync,
      initialIndex: initialIndex,
    );
    _pageController = PageController(initialPage: initialIndex);
    widget.viewModel.setCurrentIndex(initialIndex);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPageByTab(TabModel tab) {
    switch (tab.id) {
      case 'recommend':
        return const RecommendPage();
      case 'community':
        return const CommunityPage();
      // case 'club':
      //   return const ClubPage();
      case 'smart-drive':
        return const SmartDrivePage();
      case 'activity':
        final brandArg = Get.arguments is Map
            ? (Get.arguments as Map)['brand']?.toString()
            : null;
        return ActivityPage(brand: Get.parameters['brand'] ?? brandArg);
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

  void _onPageChanged(int index) {
    if (_tabController.index != index) {
      _tabController.animateTo(index);
    }
    widget.viewModel.setCurrentIndex(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DiscoverAppBar(
        viewModel: widget.viewModel,
        onSearchTap: () {},
        onMessageTap: () async {
          final canAccess = await RouteGuard.checkLoginForAction('message');
          if (canAccess) {}
        },
        child: Obx(() => widget.viewModel.visibleTabs.isEmpty
            ? const SizedBox.shrink()
            : DiscoverTabBar(
                tabs: widget.viewModel.visibleTabs,
                controller: _tabController,
                themeStyle: widget.viewModel.themeStyle,
                onTabTap: (index) {
                  _pageController.jumpToPage(index);
                },
              )),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            widget.viewModel.updateScrollOffset(notification.metrics.pixels);
          }
          return false;
        },
        child: PageView.builder(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          itemCount: widget.viewModel.visibleTabs.length,
          itemBuilder: (context, index) {
            final tab = widget.viewModel.visibleTabs[index];
            return _buildPageByTab(tab);
          },
        ),
      ),
    );
  }
}
