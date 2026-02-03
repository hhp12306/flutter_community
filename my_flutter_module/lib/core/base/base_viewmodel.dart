import 'package:get/get.dart';

/// ViewModel 状态枚举
enum ViewModelStatus {
  idle,      // 空闲
  loading,   // 加载中
  success,   // 成功
  error,     // 错误
}

/// 统一错误信息
class ViewModelError {
  final String message;
  final String? code;
  final dynamic originalError;

  ViewModelError({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// MVVM 基类 ViewModel（GetX 状态管理）
/// - 状态管理：使用 GetX（.obs / Rx），View 通过 Obx/GetX 观察，禁止在 View 中用 setState 驱动业务状态
/// - 严格 MVVM：ViewModel 不持有 BuildContext/Widget，仅暴露状态与命令；View 只做绑定与转发用户操作
/// - 提供统一的状态、错误与生命周期
abstract class BaseViewModel extends GetxController {
  // 状态管理
  final _status = ViewModelStatus.idle.obs;
  final _error = Rx<ViewModelError?>(null);
  final _isInitialized = false.obs;

  // Getters
  ViewModelStatus get status => _status.value;
  ViewModelError? get error => _error.value;
  bool get isLoading => _status.value == ViewModelStatus.loading;
  bool get isSuccess => _status.value == ViewModelStatus.success;
  bool get isError => _status.value == ViewModelStatus.error;
  bool get isInitialized => _isInitialized.value;

  /// 初始化方法（子类可重写）
  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  /// 初始化数据（子类实现）
  Future<void> initialize() async {
    // 子类实现具体初始化逻辑
  }

  /// 内部初始化方法
  Future<void> _initialize() async {
    if (_isInitialized.value) return;
    
    try {
      setStatus(ViewModelStatus.loading);
      await initialize();
      setStatus(ViewModelStatus.success);
      _isInitialized.value = true;
    } catch (e) {
      handleError(e);
    }
  }

  /// 设置状态
  void setStatus(ViewModelStatus status) {
    _status.value = status;
    if (status != ViewModelStatus.error) {
      _error.value = null;
    }
  }

  /// 处理错误
  void handleError(dynamic error, {String? message, String? code}) {
    _status.value = ViewModelStatus.error;
    _error.value = ViewModelError(
      message: message ?? _getErrorMessage(error),
      code: code,
      originalError: error,
    );
    
    // 可以在这里统一处理错误，比如显示错误提示
    onError(_error.value!);
  }

  /// 错误回调（子类可重写）
  void onError(ViewModelError error) {
    // 默认显示错误提示
    Get.snackbar('错误', error.message);
  }

  /// 获取错误消息
  String _getErrorMessage(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is Exception) {
      return error.toString();
    } else {
      return '未知错误';
    }
  }

  /// 执行异步操作（带统一错误处理）
  Future<T?> execute<T>(Future<T> Function() action, {bool showLoading = true}) async {
    try {
      if (showLoading) {
        setStatus(ViewModelStatus.loading);
      }
      
      final result = await action();
      
      if (showLoading) {
        setStatus(ViewModelStatus.success);
      }
      
      return result;
    } catch (e) {
      handleError(e);
      return null;
    }
  }

  /// 重置状态
  void reset() {
    _status.value = ViewModelStatus.idle;
    _error.value = null;
    _isInitialized.value = false;
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
