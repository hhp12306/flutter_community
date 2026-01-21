import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// 社区页面 ViewModel（MVVM 架构）
/// 负责管理社区页面的状态和业务逻辑
class CommunityViewModel extends GetxController {
  // 为每个Tab创建独立的刷新控制器
  final RefreshController featuredRefreshController = RefreshController(initialRefresh: false);
  final RefreshController latestRefreshController = RefreshController(initialRefresh: false);
  final RefreshController followingRefreshController = RefreshController(initialRefresh: false);
  
  // 每个Tab的数据列表
  final _featuredPosts = <Map<String, dynamic>>[].obs;
  final _latestPosts = <Map<String, dynamic>>[].obs;
  final _followingPosts = <Map<String, dynamic>>[].obs;
  
  // 每个Tab的分页状态
  final _featuredPage = 1.obs;
  final _latestPage = 1.obs;
  final _followingPage = 1.obs;
  final _featuredHasMore = true.obs;
  final _latestHasMore = true.obs;
  final _followingHasMore = true.obs;
  final _isInitialized = false.obs;
  
  // Getters
  List<Map<String, dynamic>> get featuredPosts => _featuredPosts;
  List<Map<String, dynamic>> get latestPosts => _latestPosts;
  List<Map<String, dynamic>> get followingPosts => _followingPosts;
  int get featuredPage => _featuredPage.value;
  int get latestPage => _latestPage.value;
  int get followingPage => _followingPage.value;
  bool get featuredHasMore => _featuredHasMore.value;
  bool get latestHasMore => _latestHasMore.value;
  bool get followingHasMore => _followingHasMore.value;
  bool get isInitialized => _isInitialized.value;
  
  /// 初始化数据
  Future<void> init() async {
    if (_isInitialized.value) return;
    
    await loadInitialData();
    _isInitialized.value = true;
  }
  
  /// 加载初始数据
  Future<void> loadInitialData() async {
    await Future.wait([
      loadFeaturedData(isRefresh: true),
      loadLatestData(isRefresh: true),
      loadFollowingData(isRefresh: true),
    ]);
  }
  
  /// 下拉刷新
  Future<void> onRefresh(String type) async {
    switch (type) {
      case '精选':
        _featuredPage.value = 1;
        _featuredHasMore.value = true;
        await loadFeaturedData(isRefresh: true);
        featuredRefreshController.refreshCompleted();
        break;
      case '最新':
        _latestPage.value = 1;
        _latestHasMore.value = true;
        await loadLatestData(isRefresh: true);
        latestRefreshController.refreshCompleted();
        break;
      case '关注':
        _followingPage.value = 1;
        _followingHasMore.value = true;
        await loadFollowingData(isRefresh: true);
        followingRefreshController.refreshCompleted();
        break;
    }
  }
  
  /// 上拉加载更多
  Future<void> onLoading(String type) async {
    switch (type) {
      case '精选':
        if (!_featuredHasMore.value) {
          featuredRefreshController.loadNoData();
          return;
        }
        _featuredPage.value++;
        await loadFeaturedData(isRefresh: false);
        if (_featuredHasMore.value) {
          featuredRefreshController.loadComplete();
        } else {
          featuredRefreshController.loadNoData();
        }
        break;
      case '最新':
        if (!_latestHasMore.value) {
          latestRefreshController.loadNoData();
          return;
        }
        _latestPage.value++;
        await loadLatestData(isRefresh: false);
        if (_latestHasMore.value) {
          latestRefreshController.loadComplete();
        } else {
          latestRefreshController.loadNoData();
        }
        break;
      case '关注':
        if (!_followingHasMore.value) {
          followingRefreshController.loadNoData();
          return;
        }
        _followingPage.value++;
        await loadFollowingData(isRefresh: false);
        if (_followingHasMore.value) {
          followingRefreshController.loadComplete();
        } else {
          followingRefreshController.loadNoData();
        }
        break;
    }
  }
  
  /// 加载精选数据
  Future<void> loadFeaturedData({bool isRefresh = false}) async {
    try {
      // TODO: 从后端获取数据
      await Future.delayed(const Duration(seconds: 1));
      
      if (isRefresh) {
        _featuredPosts.value = List.generate(10, (index) => {
          'id': 'featured_$index',
          'title': '精选帖子 $index',
          'author': '发布人$index',
          'authorId': 'user_$index',
          'carTag': '车型Tag',
          'time': '${index}小时前',
          'likeCount': 100 + index,
          'commentCount': 50 + index,
          'isFollowed': false,
        });
      } else {
        // 加载更多
        if (_featuredPage.value <= 5) {
          final newPosts = List.generate(10, (index) {
            final postIndex = _featuredPosts.length + index;
            return {
              'id': 'featured_$postIndex',
              'title': '精选帖子 $postIndex',
              'author': '发布人$postIndex',
              'authorId': 'user_$postIndex',
              'carTag': '车型Tag',
              'time': '${postIndex}小时前',
              'likeCount': 100 + postIndex,
              'commentCount': 50 + postIndex,
              'isFollowed': false,
            };
          });
          _featuredPosts.addAll(newPosts);
          _featuredHasMore.value = _featuredPage.value < 5;
        } else {
          _featuredHasMore.value = false;
        }
      }
    } catch (e) {
      Get.snackbar('错误', '加载精选数据失败: $e');
    }
  }
  
  /// 加载最新数据
  Future<void> loadLatestData({bool isRefresh = false}) async {
    try {
      // TODO: 从后端获取数据
      await Future.delayed(const Duration(seconds: 1));
      
      if (isRefresh) {
        _latestPosts.value = List.generate(10, (index) => {
          'id': 'latest_$index',
          'title': '最新帖子 $index',
          'author': '发布人$index',
          'authorId': 'user_$index',
          'carTag': '车型Tag',
          'time': '${index}分钟前',
          'likeCount': 80 + index,
          'commentCount': 40 + index,
          'isFollowed': false,
        });
      } else {
        // 加载更多
        if (_latestPage.value <= 5) {
          final newPosts = List.generate(10, (index) {
            final postIndex = _latestPosts.length + index;
            return {
              'id': 'latest_$postIndex',
              'title': '最新帖子 $postIndex',
              'author': '发布人$postIndex',
              'authorId': 'user_$postIndex',
              'carTag': '车型Tag',
              'time': '${postIndex}分钟前',
              'likeCount': 80 + postIndex,
              'commentCount': 40 + postIndex,
              'isFollowed': false,
            };
          });
          _latestPosts.addAll(newPosts);
          _latestHasMore.value = _latestPage.value < 5;
        } else {
          _latestHasMore.value = false;
        }
      }
    } catch (e) {
      Get.snackbar('错误', '加载最新数据失败: $e');
    }
  }
  
  /// 加载关注数据
  Future<void> loadFollowingData({bool isRefresh = false}) async {
    try {
      // TODO: 从后端获取数据
      await Future.delayed(const Duration(seconds: 1));
      
      if (isRefresh) {
        _followingPosts.value = List.generate(10, (index) => {
          'id': 'following_$index',
          'title': '关注帖子 $index',
          'author': '关注的人$index',
          'authorId': 'user_$index',
          'carTag': '车型Tag',
          'time': '${index}小时前',
          'likeCount': 120 + index,
          'commentCount': 60 + index,
          'isFollowed': true,
        });
      } else {
        // 加载更多
        if (_followingPage.value <= 5) {
          final newPosts = List.generate(10, (index) {
            final postIndex = _followingPosts.length + index;
            return {
              'id': 'following_$postIndex',
              'title': '关注帖子 $postIndex',
              'author': '关注的人$postIndex',
              'authorId': 'user_$postIndex',
              'carTag': '车型Tag',
              'time': '${postIndex}小时前',
              'likeCount': 120 + postIndex,
              'commentCount': 60 + postIndex,
              'isFollowed': true,
            };
          });
          _followingPosts.addAll(newPosts);
          _followingHasMore.value = _followingPage.value < 5;
        } else {
          _followingHasMore.value = false;
        }
      }
    } catch (e) {
      Get.snackbar('错误', '加载关注数据失败: $e');
    }
  }
  
  /// 更新关注状态
  void updateFollowStatus(String type, int index, bool isFollowed) {
    switch (type) {
      case '精选':
        if (index >= 0 && index < _featuredPosts.length) {
          _featuredPosts[index]['isFollowed'] = isFollowed;
        }
        break;
      case '最新':
        if (index >= 0 && index < _latestPosts.length) {
          _latestPosts[index]['isFollowed'] = isFollowed;
        }
        break;
      case '关注':
        if (index >= 0 && index < _followingPosts.length) {
          _followingPosts[index]['isFollowed'] = isFollowed;
        }
        break;
    }
  }
  
  @override
  void onClose() {
    featuredRefreshController.dispose();
    latestRefreshController.dispose();
    followingRefreshController.dispose();
    super.onClose();
  }
}
