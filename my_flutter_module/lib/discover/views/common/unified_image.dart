import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 统一图片组件
/// 根据传入的图片值自动判断类型并选用对应渲染方式，调用方无需区分。
/// - 网络图：以 http:// 或 https:// 开头
/// - SVG：路径或 URL 以 .svg 结尾
/// - 本地图（png/jpg/jpeg 等）：资产路径
class UnifiedImage extends StatelessWidget {
  /// 图片值：网络 URL 或资产路径（如 assets/xx.png、assets/xx.svg）
  final String? value;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const UnifiedImage({
    Key? key,
    required this.value,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0.0,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  bool get _isNetwork => value != null &&
      (value!.startsWith('http://') || value!.startsWith('https://'));

  bool get _isSvg =>
      value != null && value!.toLowerCase().endsWith('.svg');

  Widget build(BuildContext context) {
    if (value == null || value!.trim().isEmpty) {
      return _wrapClip(_buildPlaceholder());
    }

    if (_isNetwork) {
      if (_isSvg) {
        return _wrapClip(_buildNetworkSvg());
      }
      return _wrapClip(_buildNetworkImage());
    }

    if (_isSvg) {
      return _wrapClip(_buildAssetSvg());
    }
    return _wrapClip(_buildAssetImage());
  }

  Widget _wrapClip(Widget child) {
    if (borderRadius <= 0) return child;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: child,
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: width,
      height: height,
      child: placeholder ??
          Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
    );
  }

  Widget _buildError() {
    return SizedBox(
      width: width,
      height: height,
      child: errorWidget ??
          Container(
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.grey),
            ),
          ),
    );
  }

  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: value!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildError(),
    );
  }

  Widget _buildNetworkSvg() {
    return SvgPicture.network(
      value!,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (context) => _buildPlaceholder(),
    );
  }

  Widget _buildAssetSvg() {
    return SvgPicture.asset(
      value!,
      width: width,
      height: height,
      fit: fit,
    );
  }

  Widget _buildAssetImage() {
    return Image.asset(
      value!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => _buildError(),
    );
  }
}
