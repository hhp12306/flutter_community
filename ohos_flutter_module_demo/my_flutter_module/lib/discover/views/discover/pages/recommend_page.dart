import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:get/get.dart';
import '../../../viewmodels/recommend_viewmodel.dart';
import '../../../viewmodels/discover_viewmodel.dart';
import '../../discover/components/banner_carousel.dart';
import '../../discover/components/diamond_grid.dart';
import '../../discover/components/article_list.dart';
import '../../discover/components/component_factory.dart';

/// 推荐页面（MVVM 架构）
/// 包含：Banner轮播图、金刚区、功能组件区、精彩资讯（瀑布流）
class RecommendPage extends StatefulWidget {
  const RecommendPage({Key? key}) : super(key: key);

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage>
    with AutomaticKeepAliveClientMixin {
  late final RecommendViewModel _viewModel;

  @override
  bool get wantKeepAlive => true; // 保持页面状态

  @override
  void initState() {
    super.initState();
    // 使用 Get.put 创建 ViewModel，页面销毁时自动清理
    _viewModel = Get.put(RecommendViewModel());
    // BaseViewModel 会在 onInit 时自动调用 initialize()
  }

  @override
  void dispose() {
    // Get.put 创建的 ViewModel 会在页面销毁时自动清理
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于保持页面状态
    
    return Obx(() {
      if (_viewModel.isLoading && _viewModel.items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return SmartRefresher(
        controller: _viewModel.refreshController,
        enablePullDown: true, // 启用下拉刷新
        enablePullUp: true, // 启用上拉加载更多
        onRefresh: () => _viewModel.onRefresh(),
        onLoading: () => _viewModel.onLoading(),
      header: const ClassicHeader(
        refreshingText: '正在刷新...',
        completeText: '刷新完成',
        idleText: '下拉刷新',
        releaseText: '释放刷新',
        textStyle: TextStyle(color: Colors.black54),
      ),
      footer: ClassicFooter(
        loadingText: '正在加载...',
        noDataText: '没有更多数据了',
        idleText: '上拉加载更多',
        canLoadingText: '释放加载更多',
        textStyle: const TextStyle(color: Colors.black54),
      ),
        child: CustomScrollView(
          slivers: [
            // Banner轮播图
            if (_viewModel.banners.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0), // Tab和Banner之间的间距
                  child: Builder(
                    builder: (context) {
                      // 使用 Get.find 获取 ViewModel，如果不存在则使用默认值
                      DiscoverViewModel? discoverViewModel;
                      try {
                        discoverViewModel = Get.find<DiscoverViewModel>(tag: 'discover');
                      } catch (e) {
                        // ViewModel 不存在，使用 null
                        discoverViewModel = null;
                      }
                      
                      return BannerCarousel(
                        banners: _viewModel.banners,
                        onThemeStyleChanged: (themeStyle) {
                          // Banner切换时更新themeStyle
                          if (discoverViewModel != null) {
                            discoverViewModel.updateThemeStyle(themeStyle);
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            
            // 金刚区
            if (_viewModel.diamonds.isNotEmpty)
              SliverToBoxAdapter(
                child: DiamondGrid(diamonds: _viewModel.diamonds),
              ),
            
            // 功能组件区（热门话题、车型圈列表、专题合集等）
            // 根据后端配置动态显示组件，按sort排序
            ..._buildComponentSlivers(),
            
            // 精彩资讯（瀑布流）
            if (_viewModel.items.isNotEmpty)
              ArticleList(articles: _viewModel.items),
          ],
        ),
      );
    });
  }

  /// 构建功能组件Sliver列表
  List<Widget> _buildComponentSlivers() {
    final visibleComponents = _viewModel.components
        .where((c) => c.visible)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));
    
    return visibleComponents.map((component) {
      final widget = ComponentFactory.createComponent(component);
      return widget != null
          ? SliverToBoxAdapter(child: widget)
          : const SliverToBoxAdapter(child: SizedBox.shrink());
    }).toList();
  }
}

