import 'package:flutter/material.dart';
import '../../../models/city_model.dart';
import '../../../services/location_service.dart';
import '../../common/city_selector_page.dart';

/// 活动页面
/// 支持城市定位，切换跳转城市选择页
class ActivityPage extends StatefulWidget {
  const ActivityPage({Key? key}) : super(key: key);

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final LocationService _locationService = LocationService();
  CityModel? _currentCity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentCity();
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
      _loadActivityData();
    }
  }

  /// 加载活动数据（根据当前城市）
  Future<void> _loadActivityData() async {
    // TODO: 根据当前城市加载活动数据
    if (_currentCity != null) {
      // 调用后端API获取该城市的活动数据
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('活动'),
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
            const Text(
              '活动页面内容',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            // TODO: 显示活动列表
          ],
        ),
      ),
    );
  }
}

