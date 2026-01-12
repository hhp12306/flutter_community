import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../../../models/banner_model.dart';
import '../../../models/diamond_model.dart';
import '../../../models/article_model.dart';
import '../../../models/component_model.dart';
import '../../discover/components/banner_carousel.dart';
import '../../discover/components/diamond_grid.dart';
import '../../discover/components/article_list.dart';
import '../../discover/components/component_factory.dart';
import '../../discover/discover_provider.dart';

/// 推荐页面
/// 包含：Banner轮播图、金刚区、功能组件区、精彩资讯（瀑布流）
class RecommendPage extends StatefulWidget {
  const RecommendPage({Key? key}) : super(key: key);

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  
  // 模拟数据（实际应该从后端获取）
  List<BannerModel> _banners = [];
  List<DiamondModel> _diamonds = [];
  List<ArticleModel> _articles = [];
  List<ComponentModel> _components = []; // 功能组件列表
  bool _isLoading = false;
  int _currentPage = 1; // 当前页码
  bool _hasMore = true; // 是否还有更多数据

  @override
  void initState() {
    super.initState();
    _loadData(isRefresh: true);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    _currentPage = 1;
    _hasMore = true;
    await _loadData(isRefresh: true);
    _refreshController.refreshCompleted();
  }

  /// 上拉加载更多
  Future<void> _onLoading() async {
    if (!_hasMore) {
      _refreshController.loadNoData();
      return;
    }
    
    _currentPage++;
    await _loadMoreData();
    
    if (_hasMore) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  /// 加载数据（刷新）
  Future<void> _loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _isLoading = true;
      });
    }

    // TODO: 从后端获取数据
    // 模拟数据
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _banners = [
        BannerModel(
          id: '1',
          imageUrl: 'https://example.com/banner1.jpg',
          title: 'Banner 1',
          linkUrl: 'https://example.com/link1',
        ),
        BannerModel(
          id: '2',
          imageUrl: 'https://example.com/banner2.jpg',
          title: 'Banner 2',
          linkUrl: 'https://example.com/link2',
        ),
      ];
      
      _diamonds = List.generate(10, (index) => DiamondModel(
        id: 'diamond_$index',
        name: '功能$index',
        iconUrl: 'https://example.com/icon$index.png',
        linkUrl: 'https://example.com/link$index',
      ));
      
      // 加载功能组件（根据后端配置）
      if (isRefresh) {
        _components = _loadComponents();
      }
      
      // 刷新时重置文章列表
      if (isRefresh) {
        _articles = List.generate(20, (index) => ArticleModel(
          id: 'article_$index',
          title: '精彩资讯标题 $index',
          imageUrl: 'https://example.com/article$index.jpg',
          authorId: 'author_$index',
          authorName: '作者$index',
          authorAvatar: 'https://example.com/avatar$index.jpg',
          carTag: '车型Tag',
          likeCount: 100 + index,
          commentCount: 50 + index,
          collectCount: 30 + index,
          isTop: index < 2,
          isFeatured: index % 3 == 0,
          publishTime: DateTime.now().subtract(Duration(hours: index)).millisecondsSinceEpoch,
        ));
      }
      
      _isLoading = false;
    });
  }

  /// 加载更多数据
  Future<void> _loadMoreData() async {
    // TODO: 从后端获取更多数据
    // 模拟加载更多数据
    await Future.delayed(const Duration(seconds: 1));
    
    // 模拟数据：每页加载10条，最多5页
    if (_currentPage <= 5) {
      final newArticles = List.generate(10, (index) {
        final articleIndex = _articles.length + index;
        return ArticleModel(
          id: 'article_$articleIndex',
          title: '精彩资讯标题 $articleIndex',
          imageUrl: 'https://example.com/article$articleIndex.jpg',
          authorId: 'author_$articleIndex',
          authorName: '作者$articleIndex',
          authorAvatar: 'https://example.com/avatar$articleIndex.jpg',
          carTag: '车型Tag',
          likeCount: 100 + articleIndex,
          commentCount: 50 + articleIndex,
          collectCount: 30 + articleIndex,
          isTop: false,
          isFeatured: articleIndex % 3 == 0,
          publishTime: DateTime.now().subtract(Duration(hours: articleIndex)).millisecondsSinceEpoch,
        );
      });
      
      setState(() {
        _articles.addAll(newArticles);
        // 模拟：第5页后没有更多数据
        _hasMore = _currentPage < 5;
      });
    } else {
      setState(() {
        _hasMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true, // 启用下拉刷新
      enablePullUp: true, // 启用上拉加载更多
      onRefresh: _onRefresh,
      onLoading: _onLoading,
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
          if (_banners.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0), // Tab和Banner之间的间距
                child: Consumer<DiscoverProvider>(
                  builder: (context, provider, child) {
                    return BannerCarousel(
                      banners: _banners,
                      onThemeStyleChanged: (themeStyle) {
                        // Banner切换时更新themeStyle
                        provider.updateThemeStyle(themeStyle);
                      },
                    );
                  },
                ),
              ),
            ),
          
          // 金刚区
          if (_diamonds.isNotEmpty)
            SliverToBoxAdapter(
              child: DiamondGrid(diamonds: _diamonds),
            ),
          
          // 功能组件区（热门话题、车型圈列表、专题合集等）
          // 根据后端配置动态显示组件，按sort排序
          ..._buildComponentSlivers(),
          
          // 精彩资讯（瀑布流）
          if (_articles.isNotEmpty)
            ArticleList(articles: _articles),
        ],
      ),
    );
  }

  /// 构建功能组件Sliver列表
  List<Widget> _buildComponentSlivers() {
    final visibleComponents = _components
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

  /// 加载功能组件（模拟数据，实际应该从后端获取）
  List<ComponentModel> _loadComponents() {
    return [
      // 热门话题
      ComponentModel(
        id: 'hot_topics_1',
        key: 'hot_topics',
        name: '热门话题',
        sort: 1,
        visible: true,
        config: {
          'topics': [
            {
              'id': 'topic_1',
              'title': '新能源车使用心得',
              'imageUrl': 'https://example.com/topic1.jpg',
              'joinCount': 1234,
            },
            {
              'id': 'topic_2',
              'title': '自驾游分享',
              'imageUrl': 'https://example.com/topic2.jpg',
              'joinCount': 5678,
            },
            {
              'id': 'topic_3',
              'title': '保养经验交流',
              'imageUrl': 'https://example.com/topic3.jpg',
              'joinCount': 9012,
            },
          ],
        },
      ),
      // 车型圈列表
      ComponentModel(
        id: 'car_circle_1',
        key: 'car_circle_list',
        name: '车型圈',
        sort: 2,
        visible: true,
        config: {
          'circles': [
            {
              'id': 'circle_1',
              'name': '汉EV车友圈',
              'iconUrl': 'https://example.com/circle1.png',
              'memberCount': 5000,
              'postCount': 1200,
            },
            {
              'id': 'circle_2',
              'name': '唐DM车友圈',
              'iconUrl': 'https://example.com/circle2.png',
              'memberCount': 3000,
              'postCount': 800,
            },
          ],
        },
      ),
      // 专题合集
      ComponentModel(
        id: 'collection_1',
        key: 'topic_collection',
        name: '专题合集',
        sort: 3,
        visible: true,
        config: {
          'title': '精选专题',
          'collections': [
            {
              'id': 'collection_1',
              'title': '2024年新车盘点',
              'coverUrl': 'https://example.com/collection1.jpg',
              'description': '最新车型资讯',
              'articleCount': 50,
            },
            {
              'id': 'collection_2',
              'title': '用车技巧大全',
              'coverUrl': 'https://example.com/collection2.jpg',
              'description': '实用用车指南',
              'articleCount': 30,
            },
          ],
        },
      ),
      // 单个专题
      ComponentModel(
        id: 'topic_1',
        key: 'topic',
        name: '热门专题',
        sort: 4,
        visible: true,
        config: {
          'id': 'topic_single_1',
          'title': '智能驾驶体验',
          'coverUrl': 'https://example.com/topic_single.jpg',
          'description': '探索智能驾驶的乐趣',
          'articleCount': 25,
        },
      ),
    ];
  }
}

