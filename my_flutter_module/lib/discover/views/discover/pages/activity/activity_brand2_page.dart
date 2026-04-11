import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../../../viewmodels/activity_brand2_viewmodel.dart';
import '../../../../viewmodels/discover_viewmodel.dart';
import '../../../../models/activity_model.dart';
import '../../../common/di_image_widget.dart';
import '../../../../utils/time_util.dart';
import '../../../common/app_loading_indicator.dart';

/// 品牌2活动页：先加载当前定位城市活动，完成后显示「更多精彩活动」并加载该列表，无更多时显示「没有更多了」
class ActivityBrand2Page extends StatefulWidget {
  const ActivityBrand2Page({Key? key}) : super(key: key);

  @override
  State<ActivityBrand2Page> createState() => _ActivityBrand2PageState();
}

class _ActivityBrand2PageState extends State<ActivityBrand2Page> {
  late final ActivityBrand2ViewModel _vm;
  Worker? _activityTabWorker;

  @override
  void initState() {
    super.initState();
    _vm = Get.put(ActivityBrand2ViewModel(), tag: 'activity_brand2');
    try {
      final discover = Get.find<DiscoverViewModel>(tag: 'discover');
      debugPrint('[Activity/brand2] bind ever(activityLocationTick)');
      _activityTabWorker = ever<int>(discover.activityLocationTick, (v) {
        debugPrint('[Activity/brand2] activityLocationTick=$v -> onPageVisible');
        _vm.onPageVisible();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final i = discover.currentIndex;
        final tabs = discover.visibleTabs;
        if (i >= 0 && i < tabs.length && tabs[i].id == 'activity') {
          debugPrint(
            '[Activity/brand2] postFrame: currentIndex=$i is activity -> onPageVisible (sync)',
          );
          _vm.onPageVisible();
        }
      });
    } catch (e, st) {
      debugPrint('[Activity/brand2] DiscoverViewModel not found: $e\n$st');
    }
  }

  @override
  void dispose() {
    _activityTabWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: Obx(() {
          if (_vm.isLoading && !_vm.cityLoaded) {
            return const AppLoadingIndicator();
          }
          return SmartRefresher(
              controller: _vm.refreshController,
              enablePullDown: true,
              enablePullUp: _vm.cityHasMore || _vm.hasMore,
              onRefresh: () => _vm.onRefresh(),
              onLoading: () => _vm.onLoadMore(),
              header: const ClassicHeader(
                refreshingText: '正在刷新...',
                completeText: '刷新完成',
                idleText: '下拉刷新',
                releaseText: '释放刷新',
                textStyle: TextStyle(color: Colors.black54),
              ),
              footer: CustomFooter(
                builder: (context, mode) {
                  if (mode == LoadStatus.noMore) {
                    return _buildNoMoreWidget();
                  }
                  if (mode == LoadStatus.loading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: AppLoadingIndicator(size: 24, fit: BoxFit.cover),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              child: CustomScrollView(
                slivers: [
                  _buildCitySection(),
                  SliverToBoxAdapter(child: _buildMoreSectionHeader()),
                  _buildMoreSectionList(),
                  if (_shouldShowNoMore()) SliverToBoxAdapter(child: _buildNoMoreWidget()),
                ],
              ),
          );
        }),
    );
  }

  Widget _buildCitySection() {
    return SliverToBoxAdapter(
      child: _vm.cityLoading
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: AppLoadingIndicator(size: 48, fit: BoxFit.cover),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_vm.currentCity?.name ?? "当前城市"} · 活动',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_vm.cityActivities.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text('暂无活动', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ..._vm.cityActivities.map((a) => _buildActivityCard(a)),
                ],
              ),
            ),
    );
  }

  /// 「更多精彩活动」标题：仅当城市活动没有更多（无数据或已拉完）后才展示
  Widget _buildMoreSectionHeader() {
    if (!_vm.cityLoaded || _vm.cityHasMore) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        '更多精彩活动',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.orange.shade900,
        ),
      ),
    );
  }

  Widget _buildMoreSectionList() {
    if (!_vm.cityLoaded || _vm.cityHasMore) return const SliverToBoxAdapter(child: SizedBox.shrink());
    if (_vm.loadMoreLoading && _vm.moreActivities.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: AppLoadingIndicator(size: 48, fit: BoxFit.cover),
        ),
      );
    }
    if (_vm.moreActivities.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildActivityCard(_vm.moreActivities[index]),
          ),
          childCount: _vm.moreActivities.length,
        ),
      ),
    );
  }

  bool _shouldShowNoMore() {
    if (!_vm.cityLoaded) return false;
    if (_vm.cityHasMore) return false;
    if (_vm.loadMoreLoading) return false;
    if (_vm.hasMore) return false;
    return true;
  }

  Widget _buildNoMoreWidget() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          '没有更多了',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: DiImageWidget(
              imageUrl: activity.imageUrl ?? '',
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                _infoRow(Icons.access_time, '报名时间', _formatRegistrationTime(activity)),
                if (activity.location != null) ...[
                  const SizedBox(height: 6),
                  _infoRow(Icons.location_on, '活动地点', activity.location!),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(activity.getStatusText()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label: $value',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  String _formatRegistrationTime(ActivityModel a) {
    final start = TimeUtil.formatDateTime(
      DateTime.fromMillisecondsSinceEpoch(a.registrationStartTime),
      format: 'yyyy/MM/dd HH:mm',
    );
    final end = TimeUtil.formatDateTime(
      DateTime.fromMillisecondsSinceEpoch(a.registrationEndTime),
      format: 'yyyy/MM/dd HH:mm',
    );
    return '$start - $end';
  }
}
