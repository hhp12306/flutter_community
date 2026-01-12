import 'package:flutter/foundation.dart';
import '../services/i18n_service.dart';

/// 国际化状态管理
class I18nProvider extends ChangeNotifier {
  final I18nService _i18nService = I18nService();
  
  String get currentLanguage => _i18nService.currentLanguage;
  
  /// 初始化
  Future<void> init() async {
    await _i18nService.init();
    notifyListeners();
  }
  
  /// 获取翻译文本
  String get(String key, {Map<String, String>? params}) {
    return _i18nService.get(key, params: params);
  }
  
  /// 切换语言
  Future<void> switchLanguage(String languageCode) async {
    await _i18nService.switchLanguage(languageCode);
    notifyListeners();
  }
  
  /// 获取支持的语言列表
  List<String> getSupportedLanguages() {
    return _i18nService.getSupportedLanguages();
  }
}
