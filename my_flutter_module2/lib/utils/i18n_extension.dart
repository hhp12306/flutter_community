import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/i18n_provider.dart';

/// i18n扩展方法
/// 方便在Widget中直接使用翻译
extension I18nExtension on BuildContext {
  /// 获取翻译文本
  String i18n(String key, {Map<String, String>? params}) {
    final i18nProvider = Provider.of<I18nProvider>(this, listen: false);
    return i18nProvider.get(key, params: params);
  }
  
  /// 获取I18nProvider
  I18nProvider get i18nProvider => Provider.of<I18nProvider>(this, listen: false);
}
