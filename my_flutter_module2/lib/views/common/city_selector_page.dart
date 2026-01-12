import 'package:flutter/material.dart';
import '../../models/city_model.dart';
import '../../services/location_service.dart';

/// 城市选择页面
class CitySelectorPage extends StatefulWidget {
  final CityModel? currentCity; // 当前选中的城市

  const CitySelectorPage({
    Key? key,
    this.currentCity,
  }) : super(key: key);

  @override
  State<CitySelectorPage> createState() => _CitySelectorPageState();
}

class _CitySelectorPageState extends State<CitySelectorPage> {
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  
  List<CityModel> _hotCities = [];
  List<CityModel> _allCities = [];
  List<CityModel> _searchResults = [];
  CityModel? _currentCity;
  bool _isSearching = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentCity = widget.currentCity;
    _loadCities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 加载城市列表
  Future<void> _loadCities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hotCities = await _locationService.getHotCities();
      final allCities = await _locationService.getAllCities();
      
      setState(() {
        _hotCities = hotCities;
        _allCities = allCities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 搜索城市
  void _onSearchChanged(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _locationService.searchCities(keyword).then((results) {
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    });
  }

  /// 选择城市
  void _selectCity(CityModel city) {
    setState(() {
      _currentCity = city;
    });
    
    // 保存选择的城市
    _locationService.saveCurrentCity(city);
    
    // 返回选择的城市
    Navigator.of(context).pop(city);
  }

  /// 使用定位
  Future<void> _useLocation() async {
    // 显示加载提示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final location = await _locationService.getCurrentLocation();
      
      if (!mounted) return;
      Navigator.of(context).pop(); // 关闭加载提示

      if (location != null) {
        final city = await _locationService.getCityByLocation(location);
        
        if (city != null && mounted) {
          _selectCity(city);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('定位失败，请手动选择城市')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('定位失败，请检查定位权限')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // 关闭加载提示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('定位失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择城市'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 搜索框
                Container(
                  padding: const EdgeInsets.all(12.0),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索城市',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                
                // 定位按钮
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  color: Colors.white,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.location_on, color: Colors.blue),
                        onPressed: _useLocation,
                      ),
                      const Text(
                        '使用定位',
                        style: TextStyle(fontSize: 14.0),
                      ),
                      const Spacer(),
                      if (_currentCity != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            '当前: ${_currentCity!.name}',
                            style: const TextStyle(
                              fontSize: 12.0,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                const Divider(height: 1),
                
                // 城市列表
                Expanded(
                  child: _isSearching
                      ? _buildSearchResults()
                      : _buildCityList(),
                ),
              ],
            ),
    );
  }

  /// 构建城市列表
  Widget _buildCityList() {
    return ListView(
      children: [
        // 热门城市
        if (_hotCities.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.grey[50],
            child: const Text(
              '热门城市',
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _hotCities.map((city) {
                final isSelected = _currentCity?.id == city.id;
                return GestureDetector(
                  onTap: () => _selectCity(city),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.white,
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Text(
                      city.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
        ],
        
        // 所有城市
        Container(
          padding: const EdgeInsets.all(12.0),
          color: Colors.grey[50],
          child: const Text(
            '全部城市',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        ..._allCities.map((city) {
          final isSelected = _currentCity?.id == city.id;
          return ListTile(
            title: Text(city.name),
            trailing: isSelected
                ? const Icon(Icons.check, color: Colors.blue)
                : null,
            onTap: () => _selectCity(city),
          );
        }).toList(),
      ],
    );
  }

  /// 构建搜索结果
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Text('未找到相关城市'),
      );
    }

    return ListView(
      children: _searchResults.map((city) {
        final isSelected = _currentCity?.id == city.id;
        return ListTile(
          title: Text(city.name),
          trailing: isSelected
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: () => _selectCity(city),
        );
      }).toList(),
    );
  }
}
