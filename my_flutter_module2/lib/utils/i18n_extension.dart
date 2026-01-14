import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/i18n_controller.dart';

/// i18n扩展方法
/// 方便在Widget中直接使用翻译
extension I18nExtension on BuildContext {
  /// 获取翻译文本
  String i18n(String key, {Map<String, String>? params}) {
    final i18nController = Get.find<I18nController>();
    return i18nController.get(key, params: params);
  }
  
  /// 获取I18nController
  I18nController get i18nController => Get.find<I18nController>();
}
