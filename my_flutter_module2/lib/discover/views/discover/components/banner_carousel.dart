import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../models/banner_model.dart';

/// Banner轮播图组件
class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  final ValueChanged<int?>? onThemeStyleChanged; // themeStyle变化回调

  const BannerCarousel({
    Key? key,
    required this.banners,
    this.onThemeStyleChanged,
  }) : super(key: key);

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  @override
  void initState() {
    super.initState();
    // 初始化时通知当前themeStyle
    if (widget.banners.isNotEmpty) {
      _notifyThemeStyle(widget.banners[0].themeStyle);
    }
  }

  /// 通知themeStyle变化
  void _notifyThemeStyle(int? themeStyle) {
    widget.onThemeStyleChanged?.call(themeStyle);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return CarouselSlider(
      options: CarouselOptions(
        height: 180.0, // 调整高度
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 3),
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        enlargeCenterPage: false, // 不放大中心页
        viewportFraction: 1.0, // 全宽显示
        padEnds: false, // 移除两端padding
        onPageChanged: (index, reason) {
          // 轮播图切换时，通知themeStyle变化
          if (index < widget.banners.length) {
            _notifyThemeStyle(widget.banners[index].themeStyle);
          }
        },
      ),
      items: widget.banners.map((banner) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                // TODO: 跳转到详情页
                if (banner.linkUrl != null) {
                  // 处理跳转
                }
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 12.0), // 左右边距12px
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0), // 圆角12px
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Banner图片
                      CachedNetworkImage(
                        imageUrl: banner.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                      ),
                      // 底部左侧文字覆盖（如果有title）
                      if (banner.title != null && banner.title!.isNotEmpty)
                        Positioned(
                          left: 16.0,
                          bottom: 16.0,
                          child: Text(
                            banner.title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

