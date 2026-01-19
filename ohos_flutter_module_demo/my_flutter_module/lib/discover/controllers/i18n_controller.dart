import 'package:get/get.dart';
import '../services/i18n_service.dart';

/// 国际化状态管理（GetX Controller）
class I18nController extends GetxController {
  final I18nService _i18nService = I18nService();
  
  String get currentLanguage => _i18nService.currentLanguage;
  
  /// 初始化
  Future<void> init() async {
    await _i18nService.init();
    update(); // GetX 的更新方法
  }
  
  /// 获取翻译文本
  String get(String key, {Map<String, String>? params}) {
    return _i18nService.get(key, params: params);
  }
  
  /// 切换语言
  Future<void> switchLanguage(String languageCode) async {
    await _i18nService.switchLanguage(languageCode);
    update(); // GetX 的更新方法
  }
  
  /// 获取支持的语言列表
  List<String> getSupportedLanguages() {
    return _i18nService.getSupportedLanguages();
  }
}
