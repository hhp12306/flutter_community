import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/banner_model.dart';
import '../../discover/components/banner_carousel.dart';

/// 智驾页面
/// Banner轮播图展示区
/// 图片占位功能区，点击可跳转
class SmartDrivePage extends StatefulWidget {
  const SmartDrivePage({Key? key}) : super(key: key);

  @override
  State<SmartDrivePage> createState() => _SmartDrivePageState();
}

class _SmartDrivePageState extends State<SmartDrivePage> {
  List<BannerModel> _banners = [];
  List<Map<String, dynamic>> _functions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // TODO: 从后端获取数据
    setState(() {
      _banners = [
        BannerModel(
          id: '1',
          imageUrl: 'https://example.com/banner1.jpg',
          title: '智驾Banner',
        ),
      ];
      
      _functions = [
        {'name': '功能1', 'imageUrl': 'https://example.com/func1.jpg', 'linkUrl': 'https://example.com/link1', 'visible': true},
        {'name': '功能2', 'imageUrl': 'https://example.com/func2.jpg', 'linkUrl': 'https://example.com/link2', 'visible': true},
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        children: [
          // Banner轮播图
          if (_banners.isNotEmpty)
            BannerCarousel(banners: _banners),
          
          const SizedBox(height: 16.0),
          
          // 图片占位功能区
          if (_functions.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(12.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                childAspectRatio: 1.5,
              ),
              itemCount: _functions.length,
              itemBuilder: (context, index) {
                final func = _functions[index];
                if (func['visible'] == false) {
                  return const SizedBox.shrink();
                }
                return GestureDetector(
                  onTap: () {
                    // TODO: 跳转到对应页面
                    if (func['linkUrl'] != null) {
                      // 处理跳转
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: func['imageUrl'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

