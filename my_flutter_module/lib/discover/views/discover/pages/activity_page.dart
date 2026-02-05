import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../../viewmodels/activity_viewmodel.dart';
import '../../../models/activity_model.dart';
import '../../../models/city_model.dart';
import '../../../utils/time_util.dart';
import '../../common/city_selector_page.dart';
import '../../common/di_image_widget.dart';

/// 活动卡片封面无数据时的默认图（需放在 assets/images/ 下）
const String _activityCoverAsset = 'assets/images/nature-landscape-with-hand-holding-frame.jpg';
const String _activityCoverUrl = 'https://zos.alipayobjects.com/rmsportal/jkjgkEfvpUPVyRjUImniVslZfWPnJuuZ.png';
const String _activityCoverUrl2 = 'https://zos.alipayobjects.com/rmsportal/ODTLcjxAfvqbxHnVXCYX.png';


/// 活动页面（MVVM 架构）
/// 支持城市定位，切换跳转城市选择页
class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage>
    with AutomaticKeepAliveClientMixin {
  late final ActivityViewModel _viewModel;

  /// 为 true 时卡片封面使用 _activityCoverUrl，否则使用 _activityCoverAsset
  bool _useCoverUrl = false;
  String showImage = 'https://zos.alipayobjects.com/rmsportal/jkjgkEfvpUPVyRjUImniVslZfWPnJuuZ.png';

  @override
  bool get wantKeepAlive => true; // 保持页面状态

  @override
  void initState() {
    super.initState();
    _viewModel = Get.put(ActivityViewModel());
    // 预加载时 initialize() 会用默认/已保存城市拉数据；真正显示时由 Discover 的 onPageChanged 触发定位弹窗并重拉
  }

  @override
  void dispose() {
    // Get.put 创建的 ViewModel 会在页面销毁时自动清理
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于保持页面状态
    
    return VisibilityDetector(
      key: const Key('activity_page_visibility'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction >= 0.9) {
          _viewModel.onPageVisible();
        }
      },
      child: Obx(() => Scaffold(
      backgroundColor: Colors.white,
      body: _viewModel.isLoading && _viewModel.items.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 活动城市选择器 + 切换封面图按钮
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
                      TextButton.icon(
                        onPressed: () {
                          // setState(() => _useCoverUrl = !_useCoverUrl);
                          setState(() {
                            showImage = 'https://zos.alipayobjects.com/rmsportal/ODTLcjxAfvqbxHnVXCYX.png';
                          });
                        },
                        icon: Icon(
                          _useCoverUrl ? Icons.image : Icons.image_outlined,
                          size: 18,
                        ),
                        label: Text(_useCoverUrl ? '封面(网络)' : '封面(本地)'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      GestureDetector(
                        onTap: () async {
                          final selectedCity = await Get.to<CityModel>(
                            () => CitySelectorPage(currentCity: _viewModel.currentCity),
                          );
                          if (selectedCity != null) {
                            _viewModel.updateCityAndReload(selectedCity);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _viewModel.currentCity?.name ?? '选择城市',
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
                    child: _viewModel.items.isEmpty
                        ? Center(
                            child: _viewModel.isError
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.error_outline,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _viewModel.error?.message ?? '加载失败',
                                        style: const TextStyle(
                                          fontSize: 14.0,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () => _viewModel.onRefresh(),
                                        child: const Text('重试'),
                                      ),
                                    ],
                                  )
                                : const Text(
                                    '暂无活动',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(0),
                            itemCount: _viewModel.items.length,
                            itemBuilder: (context, index) {
                              return _buildActivityCard(_viewModel.items[index]);
                            },
                          ),
                  ),
                ),
              ],
            ),
    )),
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
          // 活动封面图（DiImageWidget：支持网络图/本地 asset，可传 thumbParams 做缩略）
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            child: DiImageWidget(
              imageUrl: showImage,
              width: double.infinity,
              height: 200.0,
              fit: BoxFit.cover,
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

