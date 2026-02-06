import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/city_model.dart';
import '../../services/location_service.dart';

/// 附近地点项
class _NearbyPlace {
  final String name;
  final String address;
  final double? lat;
  final double? lng;
  final bool isSelectedPosition;

  const _NearbyPlace({
    required this.name,
    required this.address,
    this.lat,
    this.lng,
    this.isSelectedPosition = false,
  });
}

/// 地图选点公共页面
/// 上半：搜索栏 + 地图；下半：附近地点列表，每项带「确定」按钮
class MapPointPickerPage extends StatefulWidget {
  const MapPointPickerPage({Key? key}) : super(key: key);

  @override
  State<MapPointPickerPage> createState() => _MapPointPickerPageState();
}

class _MapPointPickerPageState extends State<MapPointPickerPage> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  double? _latitude;
  double? _longitude;
  String? _selectedAddress;
  bool _loading = false;
  List<_NearbyPlace> _places = [];
  static const int _nearbyCount = 10;

  Future<void> _loadCurrentLocation() async {
    setState(() => _loading = true);
    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null && mounted) {
        setState(() {
          _latitude = location.latitude;
          _longitude = location.longitude;
          _selectedAddress = location.address;
          _loading = false;
        });
        _loadNearbyPlaces();
      } else if (mounted) {
        setState(() => _loading = false);
        _loadNearbyPlaces();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _loadNearbyPlaces();
      }
    }
  }

  void _loadNearbyPlaces() {
    final lat = _latitude ?? 22.7;
    final lng = _longitude ?? 114.3;
    setState(() {
      _places = [
        _NearbyPlace(
          name: '选中位置',
          address: _selectedAddress ?? '广东省深圳市坪山区江岭街89号',
          lat: lat,
          lng: lng,
          isSelectedPosition: true,
        ),
        const _NearbyPlace(name: '比亚迪深圳汽车生产园区(二期)', address: '广东省深圳市坪山区比亚迪路', lat: 22.71, lng: 114.31),
        const _NearbyPlace(name: '比亚迪股份有限公司(总部)', address: '广东省深圳市坪山区坪山街道', lat: 22.72, lng: 114.32),
        const _NearbyPlace(name: '启迪体育中心', address: '广东省深圳市坪山区', lat: 22.69, lng: 114.29),
        const _NearbyPlace(name: '星星科技工业园', address: '广东省深圳市坪山区', lat: 22.70, lng: 114.30),
        const _NearbyPlace(name: '深圳金迈克精密科技有限公司', address: '广东省深圳市坪山区', lat: 22.68, lng: 114.28),
        const _NearbyPlace(name: '比亚迪汽车生产园2期公寓', address: '广东省深圳市坪山区', lat: 22.71, lng: 114.31),
        const _NearbyPlace(name: '顺丰速运', address: '广东省深圳市坪山区', lat: 22.69, lng: 114.30),
        const _NearbyPlace(name: '张氏宗祠', address: '广东省深圳市坪山区', lat: 22.70, lng: 114.29),
        const _NearbyPlace(name: '坪山比亚迪2期59号厂房', address: '广东省深圳市坪山区比亚迪路', lat: 22.71, lng: 114.30),
      ];
      if (_places.length > _nearbyCount) {
        _places = _places.sublist(0, _nearbyCount);
      }
    });
  }

  void _onConfirmPlace(_NearbyPlace place) {
    Get.back(
      result: LocationModel(
        latitude: place.lat ?? _latitude ?? 0,
        longitude: place.lng ?? _longitude ?? 0,
        address: place.address,
        cityName: place.name == '选中位置' ? null : place.name,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地图选点'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '搜索地点',
                  hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 22),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),
          // 上半：地图区域
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 56, color: Colors.grey[600]),
                        const SizedBox(height: 8),
                        Text('地图区域', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                        if (_latitude != null && _longitude != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Text(
                    '腾讯地图',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    elevation: 2,
                    child: IconButton(
                      icon: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, color: Colors.blue),
                      onPressed: _loading ? null : _loadCurrentLocation,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 下半：附近地点列表
          Container(
            height: MediaQuery.of(context).size.height * 0.38,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(height: 1),
                Expanded(
                  child: _places.isEmpty
                      ? Center(
                          child: Text(
                            _loading ? '定位中...' : '点击地图右侧定位获取附近地点',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _places.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, indent: 56),
                          itemBuilder: (context, index) {
                            final place = _places[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              leading: Icon(
                                Icons.place,
                                color: Colors.red[400],
                                size: 28,
                              ),
                              title: Text(
                                place.isSelectedPosition ? '[选中位置]' : place.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  place.address,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              trailing: SizedBox(
                                width: 64,
                                height: 32,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(64, 32),
                                  ),
                                  onPressed: () => _onConfirmPlace(place),
                                  child: const Text('确定', style: TextStyle(fontSize: 13)),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
