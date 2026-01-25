import 'package:get/get.dart';
import '../../core/base/base_list_viewmodel.dart';
import '../../core/result/result.dart';
import '../models/banner_model.dart';
import '../models/diamond_model.dart';
import '../models/article_model.dart';
import '../models/component_model.dart';
import '../repositories/recommend_repository.dart';
import 'discover_viewmodel.dart';

/// 推荐页面 ViewModel（MVVM 架构 - 新架构版本）
/// 继承 BaseListViewModel，管理文章列表，同时管理其他数据（Banner、金刚区、组件）
/// 使用 Repository 层获取数据
class RecommendViewModel extends BaseListViewModel<ArticleModel> {
  final RecommendRepository _repository = RecommendRepository();
  
  // 其他数据（非列表分页数据）
  final _banners = <BannerModel>[].obs;
  final _diamonds = <DiamondModel>[].obs;
  final _components = <ComponentModel>[].obs;
  
  // Getters
  List<BannerModel> get banners => _banners;
  List<DiamondModel> get diamonds => _diamonds;
  List<ComponentModel> get components => _components;
  // articles 使用基类的 items
  List<ArticleModel> get articles => items;
  
  @override
  Future<void> initialize() async {
    await loadData(isRefresh: true);
  }
  
  @override
  Future<void> loadData({bool isRefresh = false}) async {
    if (isRefresh) {
      // 并行加载所有数据
      await Future.wait([
        _loadBanners(),
        _loadDiamonds(),
        _loadComponents(),
        _loadArticles(isRefresh: true),
      ]);
    } else {
      // 只加载文章
      await _loadArticles(isRefresh: false);
    }
  }
  
  /// 加载Banner
  Future<void> _loadBanners() async {
    final result = await _repository.getBanners();
    result.when(
      success: (data) => _banners.value = data,
      failure: (message, code, error) {
        // 网络失败时使用模拟数据
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
      },
    );
  }
  
  /// 加载金刚区
  Future<void> _loadDiamonds() async {
    final result = await _repository.getDiamonds();
    result.when(
      success: (data) => _diamonds.value = data,
      failure: (message, code, error) {
        // 网络失败时使用模拟数据
        _diamonds.value = List.generate(10, (index) => DiamondModel(
          id: 'diamond_$index',
          name: '功能$index',
          iconUrl: 'https://example.com/icon$index.png',
          linkUrl: 'https://example.com/link$index',
        ));
      },
    );
  }
  
  /// 加载功能组件
  Future<void> _loadComponents() async {
    final result = await _repository.getComponents();
    result.when(
      success: (data) => _components.value = data,
      failure: (message, code, error) {
        // 网络失败时使用模拟数据
        _components.value = _loadMockComponents();
      },
    );
  }
  
  /// 加载文章列表
  Future<void> _loadArticles({bool isRefresh = false}) async {
    final result = await _repository.getArticles(
      page: currentPage,
      pageSize: pageSize,
    );
    
    result.when(
      success: (data) {
        if (data.isEmpty && isRefresh) {
          // 网络返回空数据时使用模拟数据
          _loadMockArticles(isRefresh: isRefresh);
        } else {
          setItems(data, isRefresh: isRefresh);
        }
      },
      failure: (message, code, error) {
        // 网络失败时使用模拟数据
        if (isRefresh) {
          _loadMockArticles(isRefresh: isRefresh);
        }
      },
    );
  }
  
  @override
  Future<void> loadMoreData() async {
    await _loadArticles(isRefresh: false);
  }
  
  /// 加载模拟文章数据（降级方案）
  void _loadMockArticles({bool isRefresh = false}) {
    final articles = List.generate(20, (index) => ArticleModel(
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
    setItems(articles, isRefresh: isRefresh);
  }
  
  /// 加载模拟组件数据（降级方案）
  List<ComponentModel> _loadMockComponents() {
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
    // 通知 DiscoverViewModel 更新主题样式
    try {
      final discoverViewModel = Get.find<DiscoverViewModel>(tag: 'discover');
      discoverViewModel.updateThemeStyle(themeStyle);
    } catch (e) {
      // DiscoverViewModel 不存在，忽略
    }
  }
}
