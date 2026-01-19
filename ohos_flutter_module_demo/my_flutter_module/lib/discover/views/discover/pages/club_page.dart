import 'package:flutter/material.dart';
import '../../../models/city_model.dart';
import '../../../services/location_service.dart';
import '../../common/city_selector_page.dart';

/// 俱乐部页面
/// 支持城市定位，切换跳转城市选择页
class ClubPage extends StatefulWidget {
  const ClubPage({Key? key}) : super(key: key);

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage>
    with AutomaticKeepAliveClientMixin {
  final LocationService _locationService = LocationService();
  CityModel? _currentCity;
  bool _isLoading = true;
  bool _isInitialized = false; // 是否已初始化

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
          _isLoading = false;
        });
      } else {
        // 如果没有保存的城市，尝试定位
        final location = await _locationService.getCurrentLocation();
        if (location != null) {
          final city = await _locationService.getCityByLocation(location);
          if (city != null) {
            await _locationService.saveCurrentCity(city);
            setState(() {
              _currentCity = city;
            });
          }
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 打开城市选择页
  Future<void> _openCitySelector() async {
    final selectedCity = await Navigator.push<CityModel>(
      context,
      MaterialPageRoute(
        builder: (context) => CitySelectorPage(currentCity: _currentCity),
      ),
    );

    if (selectedCity != null) {
      setState(() {
        _currentCity = selectedCity;
      });
      // 重新加载数据
      _loadClubData();
    }
  }

  /// 加载俱乐部数据（根据当前城市）
  Future<void> _loadClubData() async {
    // TODO: 根据当前城市加载俱乐部数据
    if (_currentCity != null) {
      // 调用后端API获取该城市的俱乐部数据
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于保持页面状态
    // 只在首次加载且未完成时显示加载状态
    if (_isLoading && _currentCity == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('俱乐部'),
        elevation: 0,
        actions: [
          // 城市选择按钮
          GestureDetector(
            onTap: _openCitySelector,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, size: 18),
                  const SizedBox(width: 4.0),
                  Text(
                    _currentCity?.name ?? '选择城市',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentCity != null)
              Text(
                '当前城市: ${_currentCity!.name}',
                style: const TextStyle(fontSize: 18.0),
              ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _openCitySelector,
              child: const Text('切换城市'),
            ),
            const SizedBox(height: 32.0),
            Text(
              '俱乐部页面内容',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            // TODO: 显示俱乐部列表
          ],
        ),
      ),
    );
  }
}

