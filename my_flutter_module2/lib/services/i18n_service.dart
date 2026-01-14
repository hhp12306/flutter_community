import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 国际化服务
/// 支持动态加载语言文件，无需硬编码配置
class I18nService {
  static const String _languageKey = 'app_language';
  static const String _defaultLanguage = 'zh_CN';
  
  // 当前语言
  String _currentLanguage = _defaultLanguage;
  
  // 语言数据缓存
  Map<String, dynamic> _localizedStrings = {};
  
  // 单例模式
  static final I18nService _instance = I18nService._internal();
  factory I18nService() => _instance;
  I18nService._internal();

  /// 获取当前语言
  String get currentLanguage => _currentLanguage;

  /// 初始化：加载保存的语言设置
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey);
      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        _currentLanguage = savedLanguage;
      }
      await loadLanguage(_currentLanguage);
    } catch (e) {
      // 如果加载失败，使用默认语言
      await loadLanguage(_defaultLanguage);
    }
  }

  /// 加载指定语言
  /// 支持动态读取assets/locales目录下的语言文件
  Future<void> loadLanguage(String languageCode) async {
    try {
      // 动态加载语言文件
      // 格式：assets/locales/{languageCode}/strings.json
      // Flutter Web 可能需要不同的路径格式
      final String assetPath = kIsWeb 
          ? 'packages/my_flutter_module2/assets/locales/$languageCode/strings.json'
          : 'assets/locales/$languageCode/strings.json';
      
      final String jsonString = await rootBundle.loadString(assetPath);
      
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      
      // 递归加载子模块语言文件
      await _loadModuleFiles(languageCode, jsonMap);
      
      _localizedStrings = jsonMap;
      _currentLanguage = languageCode;
      
      // 保存当前语言设置
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      // 如果加载失败，尝试加载默认语言
      if (languageCode != _defaultLanguage) {
        await loadLanguage(_defaultLanguage);
      } else {
        // 如果默认语言也加载失败，使用空Map
        _localizedStrings = {};
      }
    }
  }

  /// 递归加载模块语言文件
  /// 支持多模块语言文件，自动读取目录下的所有JSON文件
  Future<void> _loadModuleFiles(String languageCode, Map<String, dynamic> parentMap) async {
    try {
      // 读取模块目录
      final String manifestPath = kIsWeb
          ? 'packages/my_flutter_module2/AssetManifest.json'
          : 'AssetManifest.json';
      final manifestContent = await rootBundle.loadString(manifestPath);
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      
      // 查找该语言目录下的所有JSON文件
      final String modulePrefix = 'assets/locales/$languageCode/';
      
      final moduleFiles = manifestMap.keys.where((key) {
        // 兼容 Web 和移动端的路径格式
        final normalizedKey = kIsWeb && key.startsWith('packages/')
            ? key.replaceFirst('packages/my_flutter_module2/', '')
            : key;
        return normalizedKey.startsWith(modulePrefix) && 
               normalizedKey.endsWith('.json') && 
               normalizedKey != '${modulePrefix}strings.json';
      }).toList();
      
      // 加载每个模块文件
      for (final filePath in moduleFiles) {
        try {
          // 在 Web 上可能需要使用完整路径
          final String loadPath = kIsWeb && !filePath.startsWith('packages/')
              ? 'packages/my_flutter_module2/$filePath'
              : filePath;
          final String moduleJsonString = await rootBundle.loadString(loadPath);
          final Map<String, dynamic> moduleMap = json.decode(moduleJsonString);
          
          // 提取模块名称（文件名去掉路径和扩展名）
          final String fileName = filePath.split('/').last.replaceAll('.json', '');
          
          // 合并到父Map中
          parentMap[fileName] = moduleMap;
        } catch (e) {
          // 忽略单个模块文件加载失败
          continue;
        }
      }
    } catch (e) {
      // 如果模块文件加载失败，不影响主语言文件
    }
  }

  /// 获取翻译文本
  /// 支持嵌套key，如：get('module.key') 或 get('module.submodule.key')
  String get(String key, {Map<String, String>? params}) {
    if (key.isEmpty) return key;
    
    final keys = key.split('.');
    dynamic value = _localizedStrings;
    
    // 递归查找嵌套key
    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        // 如果找不到，返回key本身
        return key;
      }
    }
    
    // 如果找到的是字符串
    if (value is String) {
      String result = value;
      
      // 替换参数
      if (params != null) {
        params.forEach((paramKey, paramValue) {
          result = result.replaceAll('{$paramKey}', paramValue);
        });
      }
      
      return result;
    }
    
    // 如果找到的不是字符串，返回key
    return key;
  }

  /// 切换语言
  Future<void> switchLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      await loadLanguage(languageCode);
    }
  }

  /// 获取支持的语言列表
  List<String> getSupportedLanguages() {
    return ['zh_CN', 'en_US'];
  }
}
