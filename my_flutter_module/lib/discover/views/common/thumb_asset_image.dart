import 'package:flutter/material.dart';
import 'package:universal_asset/universal_asset.dart';

/// 基于 [UniversalAsset] 的封装，增加缩略图参数 [thumbParams]。
///
/// [thumbParams] 格式：`{设计稿宽度},{模块名},{倍率键值名}`，英文逗号分隔。
/// 例如：`'327,community,w_1p1_details'` 或 `'375,COMMUNITY,W_1P1_DETAILS'`。
/// - 为空或 null 时不处理，直接使用 [source]。
/// - 有值时解析为 (designWidth, moduleName, ratioKey)，若 [buildThumbUrl] 非空则用其生成缩略图 URL，否则仍用 [source]。
///
/// 缩略图 URL 生成需由调用方通过 [buildThumbUrl] 注入（如对接 CDN 规则）。
class ThumbAssetImage extends StatelessWidget {
  /// 图片地址：网络 URL 或本地资源路径
  final String? source;
  /// 缩略图参数：设计稿宽度,模块名,倍率键值名。为空则不处理
  final String? thumbParams;
  /// 根据 (原地址, 设计稿宽度, 模块名, 倍率键) 生成缩略图 URL，不传则不对地址做处理
  final String? Function(String source, String designWidth, String moduleName, String ratioKey)? buildThumbUrl;

  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ThumbAssetImage({
    super.key,
    required this.source,
    this.thumbParams,
    this.buildThumbUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  /// 解析 thumbParams，返回 (designWidth, moduleName, ratioKey)，格式非法时返回 null
  static List<String>? parseThumbParams(String? thumbParams) {
    if (thumbParams == null || thumbParams.trim().isEmpty) return null;
    final parts = thumbParams.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (parts.length != 3) return null;
    return parts;
  }

  String? get _effectiveSource {
    if (source == null || source!.trim().isEmpty) return source;
    final parsed = parseThumbParams(thumbParams);
    if (parsed == null || buildThumbUrl == null) return source;
    final designWidth = parsed[0];
    final moduleName = parsed[1];
    final ratioKey = parsed[2];
    return buildThumbUrl!(source!, designWidth, moduleName, ratioKey);
  }

  @override
  Widget build(BuildContext context) {
    return UniversalAsset(
      _effectiveSource,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
    );
  }
}
