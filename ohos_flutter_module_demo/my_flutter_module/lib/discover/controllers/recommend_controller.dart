import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/banner_model.dart';
import '../models/diamond_model.dart';
import '../models/article_model.dart';
import '../models/component_model.dart';
import 'discover_controller.dart';

/// 推荐页面 Controller（MVC 架构）
/// 负责处理用户输入，协调 Model 和 View
class RecommendController extends GetxController {
  final RefreshController refreshController = RefreshController(initialRefresh: false);
  
  // 响应式变量
  final _banners = <BannerModel>[].obs;
  final _diamonds = <DiamondModel>[].obs;
  final _articles = <ArticleModel>[].obs;
  final _components = <ComponentModel>[].obs;
  final _isLoading = false.obs;
  final _currentPage = 1.obs;
  final _hasMore = true.obs;
  final _isInitialized = false.obs;
  
  // Getters
  List<BannerModel> get banners => _banners;
  List<DiamondModel> get diamonds => _diamonds;
  List<ArticleModel> get articles => _articles;
  List<ComponentModel> get components => _components;
  bool get isLoading => _isLoading.value;
  int get currentPage => _currentPage.value;
  bool get hasMore => _hasMore.value;
  bool get isInitialized => _isInitialized.value;
  
  /// 初始化数据
  Future<void> init() async {
    if (_isInitialized.value) return;
    
    await loadData(isRefresh: true);
    _isInitialized.value = true;
  }
  
  /// 下拉刷新
  Future<void> onRefresh() async {
    _currentPage.value = 1;
    _hasMore.value = true;
    await loadData(isRefresh: true);
    refreshController.refreshCompleted();
  }
  
  /// 上拉加载更多
  Future<void> onLoading() async {
    if (!_hasMore.value) {
      refreshController.loadNoData();
      return;
    }
    
    _currentPage.value++;
    await loadMoreData();
    
    if (_hasMore.value) {
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }
  
  /// 加载数据（刷新）
  Future<void> loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      _isLoading.value = true;
    }
    
    try {
      // TODO: 从后端获取数据
      // 模拟数据
      await Future.delayed(const Duration(seconds: 1));
      
      if (isRefresh) {
        _banners.value = [
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
        
        _diamonds.value = List.generate(10, (index) => DiamondModel(
          id: 'diamond_$index',
          name: '功能$index',
          iconUrl: 'https://example.com/icon$index.png',
          linkUrl: 'https://example.com/link$index',
        ));
        
        // 加载功能组件
        _components.value = _loadComponents();
        
        // 刷新时重置文章列表
        _articles.value = List.generate(20, (index) => ArticleModel(
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
    } catch (e) {
      Get.snackbar('错误', '加载数据失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  /// 加载更多数据
  Future<void> loadMoreData() async {
    try {
      // TODO: 从后端获取更多数据
      // 模拟加载更多数据
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟数据：每页加载10条，最多5页
      if (_currentPage.value <= 5) {
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
        
        _articles.addAll(newArticles);
        // 模拟：第5页后没有更多数据
        _hasMore.value = _currentPage.value < 5;
      } else {
        _hasMore.value = false;
      }
    } catch (e) {
      Get.snackbar('错误', '加载更多失败: $e');
    }
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
  
  /// 更新主题样式（由 Banner 组件调用）
  void updateThemeStyle(int? themeStyle) {
    // 通知 DiscoverController 更新主题样式
    try {
      final discoverController = Get.find<DiscoverController>(tag: 'discover');
      discoverController.updateThemeStyle(themeStyle);
    } catch (e) {
      // DiscoverController 不存在，忽略
    }
  }
  
  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
