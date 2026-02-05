import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../viewmodels/i18n_viewmodel.dart';

/// i18n扩展方法
/// 方便在Widget中直接使用翻译
extension I18nExtension on BuildContext {
  /// 获取翻译文本
  String i18n(String key, {Map<String, String>? params}) {
    final i18nViewModel = Get.find<I18nViewModel>();
    return i18nViewModel.get(key, params: params);
  }
  
  /// 获取I18nViewModel
  I18nViewModel get i18nViewModel => Get.find<I18nViewModel>();
}
