import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../models/city_model.dart';
import '../../../models/activity_model.dart';
import '../../../services/location_service.dart';
import '../../../utils/time_util.dart';
import '../../common/city_selector_page.dart';

/// 活动页面
/// 支持城市定位，切换跳转城市选择页
class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with AutomaticKeepAliveClientMixin {
  final LocationService _locationService = LocationService();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  
  CityModel? _currentCity;
  List<ActivityModel> _activities = [];
  bool _isLoading = true;
  bool _isInitialized = false; // 是否已初始化
  int _currentPage = 1; // 当前页码
  bool _hasMore = true; // 是否还有更多数据

  @override
  bool get wantKeepAlive => true; // 保持页面状态

  @override
  void initState() {
    super.initState();
    // 只在首次创建时加载数据
    if (!_isInitialized) {
      _loadCurrentCity();
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  /// 加载当前城市
  Future<void> _loadCurrentCity() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 先尝试获取保存的城市
      final savedCity = await _locationService.getSavedCity();
      
      if (savedCity != null) {
        setState(() {
          _currentCity = savedCity;
        });
      } else {
        // 如果没有保存的城市，使用默认定位城市
        final locationCity = await _locationService.getLocationCity();
        if (locationCity != null) {
          await _locationService.saveCurrentCity(locationCity);
          setState(() {
            _currentCity = locationCity;
          });
        }
      }
      
      // 加载活动数据
      await _loadActivityData();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 打开城市选择页
  Future<void> _openCitySelector() async {
    final selectedCity = await Get.to<CityModel>(
      () => CitySelectorPage(currentCity: _currentCity),
    );

    if (selectedCity != null) {
      setState(() {
        _currentCity = selectedCity;
      });
      // 重新加载数据（刷新）
      _currentPage = 1;
      _hasMore = true;
      await _loadActivityData(isRefresh: true);
    }
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    _currentPage = 1;
    _hasMore = true;
    await _loadActivityData(isRefresh: true);
    _refreshController.refreshCompleted();
  }

  /// 上拉加载更多
  Future<void> _onLoading() async {
    if (!_hasMore) {
      _refreshController.loadNoData();
      return;
    }
    
    _currentPage++;
    await _loadActivityData(isRefresh: false);
    
    if (_hasMore) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  /// 加载活动数据（根据当前城市）
  /// [isRefresh] 是否为刷新操作（true：刷新，false：加载更多）
  Future<void> _loadActivityData({bool isRefresh = false}) async {
    // TODO: 根据当前城市加载活动数据
    // 这里使用模拟数据
    await Future.delayed(const Duration(milliseconds: 500));
    
    // 模拟分页数据
    final List<ActivityModel> newActivities = [];
    final int pageSize = 10; // 每页数量
    final int startIndex = (_currentPage - 1) * pageSize;
    
    // 生成模拟数据（实际应该从后端获取）
    for (int i = 0; i < pageSize; i++) {
      final index = startIndex + i;
      if (index >= 20) {
        // 模拟只有20条数据
        _hasMore = false;
        break;
      }
      
      newActivities.add(
        ActivityModel(
          id: '${index + 1}',
          title: '测试活动 ${index + 1}',
          imageUrl: 'https://img.bydauto.com.cn/bydauto/bydauto-cms/2024/07/01/1719806400000.jpg',
          location: '广东深圳深圳坪山',
          distance: 5.6 + (index * 0.5),
          registrationStartTime: DateTime(2026, 1, 5).millisecondsSinceEpoch,
          registrationEndTime: DateTime(2026, 1, 31).millisecondsSinceEpoch,
          activityStartTime: DateTime(2026, 2, 1).millisecondsSinceEpoch,
          activityEndTime: DateTime(2026, 2, 5).millisecondsSinceEpoch,
          status: index % 3 == 0 ? 'registering' : (index % 3 == 1 ? 'registered' : 'ended'),
          cityId: _currentCity?.id,
          cityName: _currentCity?.name,
        ),
      );
    }
    
    setState(() {
      if (isRefresh) {
        // 刷新：替换所有数据
        _activities = newActivities;
      } else {
        // 加载更多：追加数据
        _activities.addAll(newActivities);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于保持页面状态
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 活动城市选择器
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Text(
                        '活动城市',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _openCitySelector,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _currentCity?.name ?? '选择城市',
                              style: const TextStyle(
                                fontSize: 14.0,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 4.0),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),
                
                // 活动列表（带下拉刷新和上拉加载更多）
                Expanded(
                  child: SmartRefresher(
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
                    child: _activities.isEmpty
                        ? const Center(
                            child: Text(
                              '暂无活动',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: _activities.length,
                            itemBuilder: (context, index) {
                              return _buildActivityCard(_activities[index]);
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  /// 构建活动卡片
  Widget _buildActivityCard(ActivityModel activity) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 活动封面图
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            child: activity.imageUrl != null
                ? CachedNetworkImage(
                    imageUrl: activity.imageUrl!,
                    width: double.infinity,
                    height: 200.0,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: double.infinity,
                      height: 200.0,
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: double.infinity,
                      height: 200.0,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    height: 200.0,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 48, color: Colors.grey),
                  ),
          ),
          
          // 活动信息
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12.0),
                
                // 报名时间
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: '报名时间',
                  value: _formatRegistrationTime(activity),
                ),
                const SizedBox(height: 8.0),
                
                // 活动地点
                if (activity.location != null)
                  _buildInfoRow(
                    icon: Icons.location_on,
                    label: '活动地点',
                    value: activity.location!,
                  ),
                if (activity.location != null) const SizedBox(height: 8.0),
                
                // 距离
                if (activity.distance != null)
                  _buildInfoRow(
                    icon: Icons.navigation,
                    label: '距离',
                    value: '${activity.distance!.toStringAsFixed(1)}km',
                  ),
                
                const SizedBox(height: 16.0),
                
                // 报名按钮
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: 处理报名逻辑
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 10.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                    ),
                    child: Text(
                      activity.getStatusText(),
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建信息行
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.0,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8.0),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14.0,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  /// 格式化报名时间
  String _formatRegistrationTime(ActivityModel activity) {
    final startTime = TimeUtil.formatDateTime(
      DateTime.fromMillisecondsSinceEpoch(activity.registrationStartTime),
      format: 'yyyy/MM/dd HH:mm',
    );
    final endTime = TimeUtil.formatDateTime(
      DateTime.fromMillisecondsSinceEpoch(activity.registrationEndTime),
      format: 'yyyy/MM/dd HH:mm',
    );
    return '$startTime - $endTime';
  }
}

