/// 统一的结果类型
/// 用于处理成功和失败的情况，避免使用 try-catch
sealed class Result<T> {
  const Result();
}

/// 成功结果
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
}

/// 失败结果
class Failure<T> extends Result<T> {
  final String message;
  final String? code;
  final dynamic error;
  
  const Failure({
    required this.message,
    this.code,
    this.error,
  });
}

/// Result 扩展方法
extension ResultExtension<T> on Result<T> {
  /// 是否为成功
  bool get isSuccess => this is Success<T>;
  
  /// 是否为失败
  bool get isFailure => this is Failure<T>;
  
  /// 获取数据（成功时返回数据，失败时返回 null）
  T? get dataOrNull => switch (this) {
    Success(data: final data) => data,
    Failure() => null,
  };
  
  /// 获取错误消息（失败时返回消息，成功时返回 null）
  String? get errorOrNull => switch (this) {
    Success() => null,
    Failure(message: final message) => message,
  };
  
  /// 处理结果
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, String? code, dynamic error) failure,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      Failure(message: final msg, code: final code, error: final err) => failure(msg, code, err),
    };
  }
  
  /// 只处理成功（链式调用）
  Result<T> onSuccess(void Function(T data) callback) {
    if (this is Success<T>) {
      callback((this as Success<T>).data);
    }
    return this;
  }
  
  /// 只处理失败（链式调用）
  Result<T> onFailure(void Function(String message, String? code, dynamic error) callback) {
    if (this is Failure<T>) {
      final failure = this as Failure<T>;
      callback(failure.message, failure.code, failure.error);
    }
    return this;
  }
}
