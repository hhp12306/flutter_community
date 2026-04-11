import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../core/base/base_viewmodel.dart';
import '../../core/result/result.dart';
import '../models/activity_model.dart';
import '../models/city_model.dart';
import '../repositories/activity_repository.dart';

/// 品牌2活动页 ViewModel
/// 仅一个「上拉加载更多」：先按页请求当前城市活动；当城市活动无数据或返回条数 < pageSize 时再请求「更多精彩活动」，之后只请求更多精彩活动接口。
class ActivityBrand2ViewModel extends BaseViewModel {
  final ActivityRepository _repository = ActivityRepository();
  final RefreshController refreshController = RefreshController(initialRefresh: false);

  final _currentCity = Rx<CityModel?>(null);
  CityModel? get currentCity => _currentCity.value;

  /// 当前城市活动列表（上拉加载更多时先逐页请求该接口，直到无数据或 < pageSize）
  final _cityActivities = <ActivityModel>[].obs;
  List<ActivityModel> get cityActivities => _cityActivities;

  /// 首屏是否已加载完成（城市活动第一页已返回）
  final _cityLoaded = false.obs;
  bool get cityLoaded => _cityLoaded.value;

  /// 首屏加载中
  final _cityLoading = false.obs;
  bool get cityLoading => _cityLoading.value;

  /// 城市活动当前页码
  int _cityPage = 1;
  static const int _cityPageSize = 10;

  /// 城市活动是否还有更多（为 false 后上拉只请求「更多精彩活动」接口）
  final _cityHasMore = true.obs;
  bool get cityHasMore => _cityHasMore.value;

  /// 更多精彩活动列表（仅当城市活动没有更多后才开始请求并展示）
  final _moreActivities = <ActivityModel>[].obs;
  List<ActivityModel> get moreActivities => _moreActivities;

  /// 更多精彩活动当前页
  int _morePage = 1;
  static const int _morePageSize = 10;

  /// 更多精彩活动是否还有更多
  final _hasMore = true.obs;
  bool get hasMore => _hasMore.value;

  /// 上拉「加载更多」请求中（城市或更多精彩二者之一）
  final _loadMoreLoading = false.obs;
  bool get loadMoreLoading => _loadMoreLoading.value;

  /// 是否已请求过定位（品牌2 内只弹一次）
  bool _locationChecked = false;

  @override
  Future<void> initialize() async {
    await _loadCityAndCityActivities();
  }

  /// 页面首次可见时请求定位，再按定位城市刷新
  Future<void> onPageVisible() async {
    debugPrint('[ActivityBrand2VM] onPageVisible called, _locationChecked=$_locationChecked');
    if (_locationChecked) {
      debugPrint('[ActivityBrand2VM] onPageVisible skip (already checked)');
      return;
    }
    _locationChecked = true;
    debugPrint('[ActivityBrand2VM] requestLocation=true -> loadCurrentCity + onRefresh');
    await loadCurrentCity(requestLocation: true);
    await onRefresh();
    debugPrint('[ActivityBrand2VM] onPageVisible done');
  }

  /// 下拉刷新：先加载当前城市活动第一页，完成后再加载更多精彩活动第一页
  Future<void> onRefresh() async {
    _cityLoaded.value = false;
    _cityPage = 1;
    _cityHasMore.value = true;
    _morePage = 1;
    _hasMore.value = true;
    _moreActivities.clear();
    await _loadCityAndCityActivities();
  }

  /// 首屏：只加载当前城市活动第一页；若返回无数据或条数 < pageSize，则视为城市没有更多，再请求「更多精彩活动」第一页
  Future<void> _loadCityAndCityActivities() async {
    setStatus(ViewModelStatus.loading);
    await loadCurrentCity(requestLocation: false);
    _cityLoading.value = true;
    final result = await _repository.getActivities(
      cityId: _currentCity.value?.id,
      page: 1,
      pageSize: _cityPageSize,
    );
    _cityLoading.value = false;
    result.when(
      success: (list) {
        if (list.isEmpty) {
          _currentCity.value ??= CityModel(id: 'shenzhen', name: '深圳');
          _cityActivities.value = _getMockCityActivities(1);
          _cityPage = 2;
          _cityHasMore.value = _getMockCityActivities(2).isNotEmpty;
        } else {
          _cityActivities.value = list;
          _cityPage = 2;
          _cityHasMore.value = list.length >= _cityPageSize;
        }
        _cityLoaded.value = true;
        setStatus(ViewModelStatus.success);
        refreshController.refreshCompleted();
        if (!_cityHasMore.value) {
          _loadMoreActivities(isRefresh: true);
        }
      },
      failure: (message, code, error) {
        _currentCity.value ??= CityModel(id: 'shenzhen', name: '深圳');
        _cityActivities.value = _getMockCityActivities(1);
        _cityPage = 2;
        _cityHasMore.value = _getMockCityActivities(2).isNotEmpty;
        _cityLoaded.value = true;
        setStatus(ViewModelStatus.success);
        refreshController.refreshCompleted();
        if (!_cityHasMore.value) {
          _loadMoreActivities(isRefresh: true);
        }
      },
    );
  }

  /// 加载更多精彩活动（cityId 为 null，仅当城市活动没有更多后才调用）
  Future<void> _loadMoreActivities({bool isRefresh = false}) async {
    if (isRefresh) {
      _morePage = 1;
      _moreActivities.clear();
      _hasMore.value = true;
    }
    final pageToLoad = _morePage;
    final result = await _repository.getActivities(
      cityId: null,
      page: pageToLoad,
      pageSize: _morePageSize,
    );
    result.when(
      success: (list) {
        final useMock = list.isEmpty;
        final items = useMock ? _getMockMoreActivities(pageToLoad) : list;
        if (isRefresh) {
          _moreActivities.value = items;
          _morePage = 2;
        } else {
          _moreActivities.addAll(items);
          _morePage++;
        }
        _hasMore.value = useMock ? _morePage <= 3 : list.length >= _morePageSize;
      },
      failure: (_, __, ___) {
        if (isRefresh) {
          _moreActivities.value = _getMockMoreActivities(1);
          _morePage = 2;
          _hasMore.value = true;
        } else {
          _moreActivities.addAll(_getMockMoreActivities(pageToLoad));
          _morePage++;
          _hasMore.value = _morePage <= 3;
        }
      },
    );
  }

  /// 唯一的上拉加载更多：若城市活动还有更多则只请求城市活动下一页；仅当城市无更多或本页条数 < pageSize 后才请求「更多精彩活动」，之后只请求更多精彩活动接口
  Future<void> onLoadMore() async {
    if (_loadMoreLoading.value) {
      refreshController.loadComplete();
      return;
    }
    if (_cityHasMore.value) {
      _loadMoreLoading.value = true;
      final result = await _repository.getActivities(
        cityId: _currentCity.value?.id,
        page: _cityPage,
        pageSize: _cityPageSize,
      );
      _loadMoreLoading.value = false;
      bool shouldLoadMoreSection = false;
      result.when(
        success: (list) {
          if (list.isEmpty) {
            final extra = _getMockCityActivities(_cityPage);
            if (extra.isEmpty) {
              _cityHasMore.value = false;
              shouldLoadMoreSection = true;
            } else {
              _cityActivities.addAll(extra);
              _cityPage++;
              _cityHasMore.value = _getMockCityActivities(_cityPage).isNotEmpty;
            }
          } else {
            _cityActivities.addAll(list);
            _cityPage++;
            final noMore = list.length < _cityPageSize;
            _cityHasMore.value = !noMore;
            if (noMore) shouldLoadMoreSection = true;
          }
        },
        failure: (_, __, ___) {
          final extra = _getMockCityActivities(_cityPage);
          if (extra.isEmpty) {
            _cityHasMore.value = false;
            shouldLoadMoreSection = true;
          } else {
            _cityActivities.addAll(extra);
            _cityPage++;
            _cityHasMore.value = _getMockCityActivities(_cityPage).isNotEmpty;
          }
        },
      );
      if (shouldLoadMoreSection) {
        await _loadMoreActivities(isRefresh: true);
      }
      refreshController.loadComplete();
      return;
    }
    if (!_hasMore.value) {
      refreshController.loadNoData();
      return;
    }
    _loadMoreLoading.value = true;
    await _loadMoreActivities(isRefresh: false);
    _loadMoreLoading.value = false;
    if (_hasMore.value) {
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }

  Future<void> loadCurrentCity({bool requestLocation = true}) async {
    debugPrint('[ActivityBrand2VM] loadCurrentCity requestLocation=$requestLocation');
    final result = await _repository.getCurrentCity(requestLocation: requestLocation);
    result.when(
      success: (city) => _currentCity.value = city,
      failure: (_, __, ___) {},
    );
  }

  /// 深圳城市活动模拟数据（分页：每页 10 条，共 3 页 30 条，便于看「加载更多」效果）
  List<ActivityModel> _getMockCityActivities(int page) {
    const cityName = '深圳';
    const cityId = 'shenzhen';
    const pageSize = 10;
    final allTitles = [
      '深圳湾周末骑行体验', '福田区新能源汽车试驾会', '南山区科技园车友沙龙', '龙岗区户外露营节', '宝安区亲子试驾活动',
      '罗湖区商圈品牌日', '盐田区海滨自驾游', '坪山区工厂参观日', '光明区田园采摘节', '大鹏新区海边露营',
      '龙华区商圈试驾日', '南山区科技园车友会', '福田中心区品牌体验', '宝安机场周边试驾', '龙岗大运试驾专场',
      '盐田海鲜街自驾游', '坪山新能源试驾', '光明绿道骑行', '大鹏较场尾沙滩节', '龙华红山试驾会',
      '西丽大学城试驾', '蛇口海上世界体验', '前海自贸区试驾', '坂田华为周边活动', '布吉商圈试驾',
      '横岗眼镜城试驾', '观澜版画村自驾', '福永凤凰山试驾', '沙井金蚝节试驾', '松岗商圈试驾',
    ];
    final allLocations = [
      '深圳湾公园', '福田会展中心', '南山科技园', '龙岗大运中心', '宝安海雅缤纷城',
      '罗湖万象城', '盐田大梅沙', '坪山比亚迪厂区', '光明农场', '大鹏较场尾',
      '龙华红山6979', '南山科技园', '福田CBD', '宝安机场', '龙岗大运',
      '盐田海鲜街', '坪山中心', '光明绿道', '大鹏沙滩', '龙华壹方城',
      '西丽大学城', '蛇口海上世界', '前海', '坂田', '布吉',
      '横岗', '观澜', '福永', '沙井', '松岗',
    ];
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, allTitles.length);
    if (start >= allTitles.length) return [];
    return List.generate(end - start, (i) {
      final idx = start + i;
      return ActivityModel(
        id: 'sz-city-$page-${i + 1}',
        title: allTitles[idx],
        imageUrl: 'https://img.bydauto.com.cn/bydauto/bydauto-cms/2024/07/01/1719806400000.jpg',
        location: '广东深圳 ${allLocations[idx]}',
        distance: 3.0 + idx * 0.8,
        registrationStartTime: DateTime(2026, 1, 5).millisecondsSinceEpoch,
        registrationEndTime: DateTime(2026, 1, 31).millisecondsSinceEpoch,
        activityStartTime: DateTime(2026, 2, 1 + (idx % 28)).millisecondsSinceEpoch,
        activityEndTime: DateTime(2026, 2, 5 + (idx % 28)).millisecondsSinceEpoch,
        status: idx % 3 == 0 ? 'registering' : (idx % 3 == 1 ? 'registered' : 'ended'),
        cityId: cityId,
        cityName: cityName,
      );
    });
  }

  /// 更多精彩活动模拟数据（分页：第1页10条、第2页10条、第3页5条后没有更多）
  List<ActivityModel> _getMockMoreActivities(int page) {
    const pageSize = 10;
    final allTitles = [
      '全国巡回试驾 · 广州站', '全国巡回试驾 · 北京站', '全国巡回试驾 · 上海站',
      '跨城自驾游 · 深圳-惠州', '跨城自驾游 · 深圳-东莞', '品牌体验日 · 杭州',
      '品牌体验日 · 成都', '新能源技术沙龙', '车主故事分享会', '周末家庭日',
      '春节返乡试驾', '五一长假自驾', '暑期亲子营', '金秋采摘节', '冬日暖阳行',
      '新年开门红活动', '女神节专场', '儿童节亲子试驾', '中秋团圆活动', '国庆自驾游',
      '双十一购车节', '年终答谢会',
    ];
    final start = (page - 1) * pageSize;
    final end = (start + pageSize).clamp(0, allTitles.length);
    if (start >= allTitles.length) return [];
    return List.generate(end - start, (i) {
      final idx = start + i;
      return ActivityModel(
        id: 'more-${page}-${i + 1}',
        title: allTitles[idx],
        imageUrl: 'https://img.bydauto.com.cn/bydauto/bydauto-cms/2024/07/01/1719806400000.jpg',
        location: '多城市',
        distance: 10.0 + idx,
        registrationStartTime: DateTime(2026, 1, 1).millisecondsSinceEpoch,
        registrationEndTime: DateTime(2026, 12, 31).millisecondsSinceEpoch,
        activityStartTime: DateTime(2026, 3 + (idx % 6), 1).millisecondsSinceEpoch,
        activityEndTime: DateTime(2026, 3 + (idx % 6), 5).millisecondsSinceEpoch,
        status: idx % 2 == 0 ? 'registering' : 'registered',
        cityId: null,
        cityName: null,
      );
    });
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
