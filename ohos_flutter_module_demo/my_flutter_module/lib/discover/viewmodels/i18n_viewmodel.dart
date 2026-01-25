import 'package:get/get.dart';
import '../../core/base/base_viewmodel.dart';
import '../services/i18n_service.dart';

/// 国际化 ViewModel（MVVM 架构 - 新架构版本）
/// 负责管理国际化相关的状态和逻辑
class I18nViewModel extends BaseViewModel {
  final I18nService _i18nService = I18nService();
  
  String get currentLanguage => _i18nService.currentLanguage;
  
  @override
  Future<void> initialize() async {
    await _i18nService.init();
  }
  
  /// 获取翻译文本
  String get(String key, {Map<String, String>? params}) {
    return _i18nService.get(key, params: params);
  }
  
  /// 切换语言
  Future<void> switchLanguage(String languageCode) async {
    await execute(() async {
      await _i18nService.switchLanguage(languageCode);
    }, showLoading: false);
  }
  
  /// 获取支持的语言列表
  List<String> getSupportedLanguages() {
    return _i18nService.getSupportedLanguages();
  }
}
