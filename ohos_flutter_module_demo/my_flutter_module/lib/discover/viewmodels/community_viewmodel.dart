import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../core/base/base_viewmodel.dart';
import '../../core/result/result.dart';
import '../repositories/community_repository.dart';

/// 社区页面 ViewModel（MVVM 架构 - 新架构版本）
/// 负责管理社区页面的状态和业务逻辑
/// 注意：有3个独立的Tab列表，每个都有自己的分页状态
/// 使用 Repository 层获取数据
class CommunityViewModel extends BaseViewModel {
  final CommunityRepository _repository = CommunityRepository();
  
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
  
  @override
  Future<void> initialize() async {
    await loadInitialData();
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
    final result = await _repository.getFeaturedPosts(
      page: _featuredPage.value,
      pageSize: 10,
    );
    
    result.when(
      success: (data) {
        if (isRefresh) {
          _featuredPosts.value = data.isEmpty ? _generateMockPosts('featured', 10) : data;
        } else {
          if (data.length >= 10) {
            _featuredPosts.addAll(data);
            _featuredHasMore.value = true;
          } else {
            _featuredPosts.addAll(data);
            _featuredHasMore.value = false;
          }
        }
      },
      failure: (message, code, error) {
        // 网络失败时使用模拟数据
        if (isRefresh) {
          _featuredPosts.value = _generateMockPosts('featured', 10);
        }
      },
    );
  }
  
  /// 生成模拟帖子数据
  List<Map<String, dynamic>> _generateMockPosts(String type, int count) {
    return List.generate(count, (index) => {
      'id': '${type}_$index',
      'title': '${type == 'featured' ? '精选' : type == 'latest' ? '最新' : '关注'}帖子 $index',
      'author': '发布人$index',
      'authorId': 'user_$index',
      'carTag': '车型Tag',
      'time': type == 'latest' ? '${index}分钟前' : '${index}小时前',
      'likeCount': 100 + index,
      'commentCount': 50 + index,
      'isFollowed': type == 'following',
    });
  }
  
  /// 加载最新数据
  Future<void> loadLatestData({bool isRefresh = false}) async {
    final result = await _repository.getLatestPosts(
      page: _latestPage.value,
      pageSize: 10,
    );
    
    result.when(
      success: (data) {
        if (isRefresh) {
          _latestPosts.value = data.isEmpty ? _generateMockPosts('latest', 10) : data;
        } else {
          if (data.length >= 10) {
            _latestPosts.addAll(data);
            _latestHasMore.value = true;
          } else {
            _latestPosts.addAll(data);
            _latestHasMore.value = false;
          }
        }
      },
      failure: (message, code, error) {
        // 网络失败时使用模拟数据
        if (isRefresh) {
          _latestPosts.value = _generateMockPosts('latest', 10);
        }
      },
    );
  }
  
  /// 加载关注数据
  Future<void> loadFollowingData({bool isRefresh = false}) async {
    final result = await _repository.getFollowingPosts(
      page: _followingPage.value,
      pageSize: 10,
    );
    
    result.when(
      success: (data) {
        if (isRefresh) {
          _followingPosts.value = data.isEmpty ? _generateMockPosts('following', 10) : data;
        } else {
          if (data.length >= 10) {
            _followingPosts.addAll(data);
            _followingHasMore.value = true;
          } else {
            _followingPosts.addAll(data);
            _followingHasMore.value = false;
          }
        }
      },
      failure: (message, code, error) {
        // 网络失败时使用模拟数据
        if (isRefresh) {
          _followingPosts.value = _generateMockPosts('following', 10);
        }
      },
    );
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
