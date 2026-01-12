import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_routes.dart';

/// 图片展示组件
/// 支持单图、多图、视频封面等展示
class ImageDisplay extends StatelessWidget {
  final String? imageUrl; // 图片URL
  final String? videoUrl; // 视频URL（如果有，显示视频封面）
  final List<String>? imageUrls; // 多图列表
  final double? width; // 宽度
  final double? height; // 高度
  final BoxFit fit; // 图片适配方式
  final double borderRadius; // 圆角半径
  final bool showVideoIcon; // 是否显示视频播放图标
  final VoidCallback? onTap; // 点击回调
  final bool enablePreview; // 是否启用预览（点击查看大图）

  const ImageDisplay({
    Key? key,
    this.imageUrl,
    this.videoUrl,
    this.imageUrls,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
    this.showVideoIcon = true,
    this.onTap,
    this.enablePreview = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 优先使用多图列表
    if (imageUrls != null && imageUrls!.isNotEmpty) {
      return _buildMultiImage(context);
    }
    
    // 单图或视频封面
    return _buildSingleImage(context);
  }

  /// 构建单图
  Widget _buildSingleImage(BuildContext context) {
    final url = videoUrl ?? imageUrl;
    
    if (url == null || url.isEmpty) {
      return _buildPlaceholder();
    }

    // 如果borderRadius大于0，只应用顶部圆角（用于卡片顶部图片）
    final BorderRadius? clipRadius = borderRadius > 0
        ? BorderRadius.only(
            topLeft: Radius.circular(borderRadius),
            topRight: Radius.circular(borderRadius),
          )
        : null;

    Widget imageWidget = clipRadius != null
        ? ClipRRect(
            borderRadius: clipRadius,
            child: CachedNetworkImage(
              imageUrl: url,
              width: width,
              height: height,
              fit: fit,
              placeholder: (context, url) => Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.grey),
              ),
            ),
          )
        : CachedNetworkImage(
            imageUrl: url,
            width: width,
            height: height,
            fit: fit,
            placeholder: (context, url) => Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.error, color: Colors.grey),
            ),
          );

    // 如果是视频，添加播放图标
    if (videoUrl != null && showVideoIcon) {
      imageWidget = Stack(
        children: [
          imageWidget,
          Positioned.fill(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // 跳转到视频播放页
                  if (onTap != null) {
                    onTap!();
                  } else {
                    context.push(
                      '${AppRoutes.videoPlayer}?url=${Uri.encodeComponent(videoUrl!)}',
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 添加点击事件
    if (onTap != null || enablePreview) {
      return GestureDetector(
        onTap: () {
          if (onTap != null) {
            onTap!();
          } else if (enablePreview && imageUrl != null) {
            // TODO: 实现图片预览功能
            _showImagePreview(context, imageUrl!);
          }
        },
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  /// 构建多图
  Widget _buildMultiImage(BuildContext context) {
    final count = imageUrls!.length;
    
    if (count == 1) {
      // 只有一张图，按单图处理
      return ImageDisplay(
        imageUrl: imageUrls![0],
        width: width,
        height: height,
        fit: fit,
        borderRadius: borderRadius,
        onTap: onTap,
        enablePreview: enablePreview,
      );
    }

    // 多图网格布局
    if (count <= 4) {
      // 2x2网格
      return _buildGrid(context, 2, imageUrls!);
    } else if (count <= 9) {
      // 3x3网格
      return _buildGrid(context, 3, imageUrls!);
    } else {
      // 超过9张，显示前9张，并显示更多标识
      return _buildGrid(context, 3, imageUrls!.take(9).toList(), showMore: true);
    }
  }

  /// 构建网格布局
  Widget _buildGrid(
    BuildContext context,
    int crossAxisCount,
    List<String> urls, {
    bool showMore = false,
  }) {
    final itemWidth = width != null ? (width! - (crossAxisCount - 1) * 4) / crossAxisCount : null;
    final itemHeight = height != null ? (height! - (crossAxisCount - 1) * 4) / crossAxisCount : null;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          childAspectRatio: itemWidth != null && itemHeight != null
              ? itemWidth / itemHeight
              : 1.0,
        ),
        itemCount: showMore ? 10 : urls.length, // 最后一项显示"更多"
        itemBuilder: (context, index) {
          if (showMore && index == 9) {
            // 显示"更多"标识
            return Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              child: Center(
                child: Text(
                  '+${urls.length - 9}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CachedNetworkImage(
              imageUrl: urls[index],
              width: itemWidth,
              height: itemHeight,
              fit: fit,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建占位符
  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2.0),
      ),
    );
  }


  /// 显示图片预览
  void _showImagePreview(BuildContext context, String imageUrl) {
    // TODO: 实现图片预览功能
    // 可以使用第三方库如 photo_view
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
