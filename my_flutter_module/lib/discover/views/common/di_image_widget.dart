import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// 业务图片组件
class DiImageWidget extends StatelessWidget {
  const DiImageWidget({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.placeholder,
    this.errorWidget,
    this.color,
    this.headers,

    /// 新增参数
    this.thumbParams,
    this.memory,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Alignment alignment;
  final String? placeholder;
  final String? errorWidget;
  final Color? color;
  final Map<String, String>? headers;

  /// 缩略图参数（格式如 "宽,模块名,倍率"），仅对网络图生效
  final String? thumbParams;

  /// Memory data for the asset (alternative to source)
  final Uint8List? memory;

  final String? semanticLabel;
  final bool excludeFromSemantics;

  static const List<String> _imageExtensions = [
    'png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp',
  ];

  /// 处理图片地址：网络图且 thumbParams 合法时拼接缩略图参数
  static String _handleImageUrl(String imageUrl, String? params) {
    if (!_isNetworkUrl(imageUrl)) return imageUrl;
    if (params == null ||
        params.trim().isEmpty ||
        params.trim().split(',').length != 3) {
      return imageUrl;
    }
    final separator = imageUrl.contains('?') ? '&' : '?';
    return '$imageUrl${separator}thumb=$params';
  }

  /// 是否图片资源
  static bool _isImage(String source) {
    final extension = _getFileExtension(source);
    return extension.isNotEmpty && _imageExtensions.contains(extension);
  }

  /// 是否 svg 资源
  static bool _isSvg(String source) {
    return _getFileExtension(source) == 'svg';
  }

  /// 获取文件扩展名
  static String _getFileExtension(String source) {
    final Uri? uri = Uri.tryParse(source);
    final String path = uri?.path ?? source;
    final int lastDot = path.lastIndexOf('.');

    if (lastDot == -1 || lastDot == path.length - 1) {
      return '';
    }

    return path.substring(lastDot + 1).toLowerCase();
  }

  /// 判断图片地址是否为网络图片
  static bool _isNetworkUrl(String source) {
    return source.startsWith('http://') || source.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty && memory == null) {
      return _buildErrorWidget(context, 'No source or memory data provided');
    }
    try {
      return _buildAssetWidget(context);
    } catch (e, stack) {
      assert(() {
        debugPrint('DiImageWidget build error: $e\n$stack');
        return true;
      }());
      return _buildErrorWidget(context, 'Failed to load: $e');
    }
  }

  /// 获取默认占位图
  static Widget _placeholderImage(String? source) {
    return Image.asset(
        source ?? 'assets/images/discovery/community_def_cover_5_to_4.webp',
        fit: BoxFit.cover);
  }

  Widget _buildAssetWidget(BuildContext context) {
    if (memory != null) {
      return _renderImageMemory(context, memory!);
    }

    /// 图片
    if (_isImage(imageUrl)) {
      if (_isNetworkUrl(imageUrl)) {
        // 网络图片
        return _renderCachedNetworkImage(context);
      } else {
        return _renderImage(context);
      }
    }

    if (_isSvg(imageUrl)) {
      final resolvedFit = fit ?? BoxFit.cover;
      if (_isNetworkUrl(imageUrl)) {
        return SvgPicture.network(
          imageUrl,
          width: width,
          height: height,
          headers: headers,
          fit: resolvedFit,
          semanticsLabel: semanticLabel,
          alignment: alignment,
          excludeFromSemantics: excludeFromSemantics,
          color: color,
          placeholderBuilder: (BuildContext context) =>
              _placeholderImage(placeholder),
        );
      } else {
        return SvgPicture.asset(
          imageUrl,
          width: width,
          height: height,
          fit: resolvedFit,
          semanticsLabel: semanticLabel,
          alignment: alignment,
          excludeFromSemantics: excludeFromSemantics,
          color: color,
          placeholderBuilder: (BuildContext context) =>
              _placeholderImage(placeholder),
        );
      }
    }

    return _buildErrorWidget(context,
        'Unsupported asset type: ${imageUrl.isNotEmpty ? imageUrl : 'memory'}');
  }

  /// Builds image memory widget
  Widget _renderImageMemory(
      BuildContext context, Uint8List memory) {
    try {
      final Widget imageWidget = Image.memory(
        memory,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        alignment: alignment,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return errorWidget != null ? _placeholderImage(errorWidget) :
          _buildErrorWidget(context, 'Failed to load memory image');
        },
      );
      return imageWidget;
    } catch (e) {
      return _buildErrorWidget(context, 'Memory image rendering failed');
    }
  }

  /// Builds cache image network widget
  Widget _renderCachedNetworkImage(BuildContext context) {
    final resolvedUrl = _handleImageUrl(imageUrl, thumbParams);
    final resolvedFit = fit ?? BoxFit.cover;
    return CachedNetworkImage(
      imageUrl: resolvedUrl,
      width: width,
      height: height,
      fit: resolvedFit,
      alignment: alignment,
      httpHeaders: headers,
      placeholder: (BuildContext context, String url) =>
          _placeholderImage(placeholder),
      errorWidget: (BuildContext context, String url, Object error) =>
          _placeholderImage(errorWidget),
    );
  }

  /// Builds image widget
  Widget _renderImage(BuildContext context) {
    try {
      final Widget imageWidget = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        alignment: alignment,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return errorWidget != null ? _placeholderImage(errorWidget) :
          _buildErrorWidget(context, 'Failed to load image: $imageUrl');
        },
        frameBuilder: (BuildContext context, Widget child, int? frame,
            bool wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            return child;
          }

          if (placeholder != null) {
            return _placeholderImage(placeholder);
          }

          return SizedBox(
            width: width,
            height: height,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      );

      return imageWidget;
    } catch (e) {
      return errorWidget != null ? _placeholderImage(errorWidget) :
      _buildErrorWidget(context, 'Image rendering failed');
    }
  }

  /// Builds error widget with fallback
  Widget _buildErrorWidget(BuildContext context, String message) {
    if (errorWidget != null) {
      return _placeholderImage(errorWidget);
    }

    return Container(
      width: width,
      height: height,
      constraints: const BoxConstraints(
        minWidth: 100,
        minHeight: 100,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
      ),
    );
  }
}