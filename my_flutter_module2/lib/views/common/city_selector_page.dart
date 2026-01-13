import 'package:flutter/material.dart';
import '../../models/city_model.dart';
import '../../services/location_service.dart';

/// 城市选择页面
/// 支持字母索引、按字母分组、模糊搜索
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
  final ScrollController _scrollController = ScrollController();
  
  List<CityModel> _hotCities = [];
  Map<String, List<CityModel>> _groupedCities = {}; // 按字母分组的城市
  List<String> _letters = []; // 字母列表（A-Z）
  List<CityModel> _searchResults = [];
  CityModel? _currentCity;
  bool _isSearching = false;
  bool _isLoading = true;
  String? _selectedLetter; // 当前选中的字母（用于高亮）

  @override
  void initState() {
    super.initState();
    _currentCity = widget.currentCity;
    _loadCities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载城市列表并按字母分组
  Future<void> _loadCities() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hotCities = await _locationService.getHotCities();
      final allCities = await _locationService.getAllCities();
      
      // 按字母分组
      final grouped = <String, List<CityModel>>{};
      final letters = <String>[];
      
      // 过滤掉热门城市，避免重复
      final nonHotCities = allCities.where((city) => !city.isHot).toList();
      
      // 按首字母分组
      for (final city in nonHotCities) {
        final letter = city.initialLetter ?? city.getInitialLetter();
        if (!grouped.containsKey(letter)) {
          grouped[letter] = [];
          letters.add(letter);
        }
        grouped[letter]!.add(city);
      }
      
      // 按字母排序
      letters.sort();
      
      // 对每个字母组内的城市按名称排序
      for (final letter in letters) {
        grouped[letter]!.sort((a, b) => a.name.compareTo(b.name));
      }
      
      setState(() {
        _hotCities = hotCities;
        _groupedCities = grouped;
        _letters = letters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 搜索城市（模糊搜索）
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

  /// 滚动到指定字母组
  void _scrollToLetter(String letter) {
    // 找到该字母组的索引位置
    double offset = 0.0;
    
    // 热门城市的高度（如果有）
    if (_hotCities.isNotEmpty) {
      offset += 100.0; // 热门城市区域大约高度
    }
    
    // 计算前面字母组的高度
    for (final l in _letters) {
      if (l == letter) break;
      final cities = _groupedCities[l] ?? [];
      offset += 50.0 + (cities.length * 56.0); // 标题高度 + 城市项高度
    }
    
    // 滚动到指定位置
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    setState(() {
      _selectedLetter = letter;
    });
    
    // 1秒后取消高亮
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _selectedLetter = null;
        });
      }
    });
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
                // 搜索框（顶部模糊搜索）
                Container(
                  padding: const EdgeInsets.all(12.0),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '搜索城市名称',
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
                
                // 城市列表（带字母索引）
                Expanded(
                  child: _isSearching
                      ? _buildSearchResults()
                      : _buildCityListWithIndex(),
                ),
              ],
            ),
    );
  }

  /// 构建带字母索引的城市列表
  Widget _buildCityListWithIndex() {
    return Stack(
      children: [
        // 城市列表
        ListView.builder(
          controller: _scrollController,
          itemCount: _getTotalItemCount(),
          itemBuilder: (context, index) {
            return _buildListItem(index);
          },
        ),
        
        // 右侧字母索引
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          child: _buildLetterIndex(),
        ),
      ],
    );
  }

  /// 获取列表项总数
  int _getTotalItemCount() {
    int count = 0;
    
    // 热门城市区域
    if (_hotCities.isNotEmpty) {
      count += 2; // 标题 + 热门城市容器
    }
    
    // 每个字母组：标题 + 城市列表
    for (final letter in _letters) {
      count += 1; // 字母标题
      count += _groupedCities[letter]?.length ?? 0; // 城市项
    }
    
    return count;
  }

  /// 构建列表项
  Widget _buildListItem(int index) {
    int currentIndex = 0;
    
    // 热门城市区域
    if (_hotCities.isNotEmpty) {
      if (index == currentIndex) {
        // 热门城市标题
        return Container(
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
        );
      }
      currentIndex++;
      
      if (index == currentIndex) {
        // 热门城市列表
        return Container(
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
        );
      }
      currentIndex++;
    }
    
    // 字母分组城市
    for (final letter in _letters) {
      final cities = _groupedCities[letter] ?? [];
      
      // 字母标题
      if (index == currentIndex) {
        return _buildLetterHeader(letter);
      }
      currentIndex++;
      
      // 该字母下的城市列表
      for (final city in cities) {
        if (index == currentIndex) {
          return _buildCityItem(city);
        }
        currentIndex++;
      }
    }
    
    return const SizedBox.shrink();
  }

  /// 构建字母标题
  Widget _buildLetterHeader(String letter) {
    final isSelected = _selectedLetter == letter;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          color: isSelected ? Colors.blue : Colors.black54,
        ),
      ),
    );
  }

  /// 构建城市项
  Widget _buildCityItem(CityModel city) {
    final isSelected = _currentCity?.id == city.id;
    return ListTile(
      title: Text(city.name),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () => _selectCity(city),
    );
  }

  /// 构建右侧字母索引
  Widget _buildLetterIndex() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 热门城市索引（如果有）
          if (_hotCities.isNotEmpty)
            GestureDetector(
              onTap: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Text(
                  '热',
                  style: TextStyle(
                    fontSize: 10.0,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          
          // 字母索引
          ..._letters.map((letter) {
            final isSelected = _selectedLetter == letter;
            return GestureDetector(
              onTap: () => _scrollToLetter(letter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: isSelected ? Colors.blue : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
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
          subtitle: city.province != null ? Text(city.province!) : null,
          trailing: isSelected
              ? const Icon(Icons.check, color: Colors.blue)
              : null,
          onTap: () => _selectCity(city),
        );
      }).toList(),
    );
  }
}
