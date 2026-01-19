import 'dart:convert';

/// Flutter与H5页面通信服务
/// 使用JSBridge方式实现双向通信
class H5BridgeService {
  // 单例模式
  static final H5BridgeService _instance = H5BridgeService._internal();
  factory H5BridgeService() => _instance;
  H5BridgeService._internal();

  // 回调函数映射（用于处理H5的回调）
  final Map<String, Function> _callbacks = {};
  int _callbackId = 0;

  /// ========== Flutter调用H5方法 ==========
  
  /// 调用H5的JavaScript方法
  /// [webViewController] WebViewController实例
  /// [methodName] 要调用的JavaScript方法名
  /// [params] 方法参数（Map格式，会自动转换为JSON）
  /// [callback] 回调函数（可选，用于接收H5返回的结果）
  Future<void> callH5Method(
    dynamic webViewController,
    String methodName, {
    Map<String, dynamic>? params,
    Function(dynamic)? callback,
  }) async {
    try {
      // 生成回调ID
      String? callbackId;
      if (callback != null) {
        callbackId = 'callback_${_callbackId++}';
        _callbacks[callbackId] = callback;
      }

      // 构建JavaScript代码
      final jsCode = _buildJSCode(methodName, params, callbackId);
      
      // 执行JavaScript代码
      if (webViewController != null) {
        // webview_flutter库的调用方式
        await webViewController.runJavaScript(jsCode);
      }
    } catch (e) {
      print('调用H5方法失败: $e');
      if (callback != null) {
        callback({'success': false, 'error': e.toString()});
      }
    }
  }

  /// 构建JavaScript调用代码
  String _buildJSCode(String methodName, Map<String, dynamic>? params, String? callbackId) {
    final paramsJson = params != null ? jsonEncode(params) : '{}';
    
    if (callbackId != null) {
      // 带回调的调用
      return '''
        (function() {
          if (window.$methodName && typeof window.$methodName === 'function') {
            try {
              window.$methodName($paramsJson, function(result) {
                window.flutter_inappwebview?.callHandler('h5Callback', {
                  'callbackId': '$callbackId',
                  'result': result
                });
              });
            } catch(e) {
              window.flutter_inappwebview?.callHandler('h5Callback', {
                'callbackId': '$callbackId',
                'error': e.toString()
              });
            }
          } else {
            window.flutter_inappwebview?.callHandler('h5Callback', {
              'callbackId': '$callbackId',
              'error': 'Method $methodName not found'
            });
          }
        })();
      ''';
    } else {
      // 不带回调的调用
      return '''
        (function() {
          if (window.$methodName && typeof window.$methodName === 'function') {
            try {
              window.$methodName($paramsJson);
            } catch(e) {
              console.error('Error calling $methodName:', e);
            }
          }
        })();
      ''';
    }
  }

  /// ========== 处理H5的回调 ==========
  
  /// 处理H5的回调结果
  /// 这个方法应该被WebView的JavaScript Handler调用
  void handleH5Callback(String callbackId, dynamic result, {String? error}) {
    final callback = _callbacks.remove(callbackId);
    if (callback != null) {
      if (error != null) {
        callback({'success': false, 'error': error});
      } else {
        callback({'success': true, 'data': result});
      }
    }
  }

  /// ========== H5调用Flutter方法（需要在WebView中注入） ==========
  
  /// 生成注入到H5的JavaScript Bridge代码
  /// 这个代码需要注入到WebView中，使H5可以通过window.FlutterBridge调用Flutter方法
  String generateBridgeJS() {
    return '''
      (function() {
        // 创建FlutterBridge对象
        window.FlutterBridge = {
          // 调用Flutter方法
          callFlutter: function(method, params, callback) {
            var callbackId = null;
            if (callback && typeof callback === 'function') {
              callbackId = 'h5_callback_' + Date.now() + '_' + Math.random();
              window._flutterCallbacks = window._flutterCallbacks || {};
              window._flutterCallbacks[callbackId] = callback;
            }
            
            // 使用postMessage发送消息到Flutter（webview_flutter方式）
            if (window.flutter_inappwebview) {
              window.flutter_inappwebview.callHandler('flutterMethod', {
                'method': method,
                'params': params || {},
                'callbackId': callbackId
              });
            } else if (window.postMessage) {
              window.postMessage(JSON.stringify({
                'type': 'flutter_method',
                'method': method,
                'params': params || {},
                'callbackId': callbackId
              }), '*');
            }
          },
          
          // 注册H5方法供Flutter调用
          registerMethod: function(methodName, handler) {
            if (!window._h5Methods) {
              window._h5Methods = {};
            }
            window._h5Methods[methodName] = handler;
          },
          
          // 触发H5回调
          triggerCallback: function(callbackId, result, error) {
            if (window._flutterCallbacks && window._flutterCallbacks[callbackId]) {
              var callback = window._flutterCallbacks[callbackId];
              delete window._flutterCallbacks[callbackId];
              if (error) {
                callback({'success': false, 'error': error});
              } else {
                callback({'success': true, 'data': result});
              }
            }
          }
        };
        
        console.log('FlutterBridge initialized');
      })();
    ''';
  }

  /// ========== 常用方法封装 ==========
  
  /// 发送登录状态给H5
  Future<void> sendLoginStatusToH5(dynamic webViewController, bool isLoggedIn, {Map<String, dynamic>? userInfo}) async {
    await callH5Method(
      webViewController,
      'onLoginStatusChanged',
      params: {
        'isLoggedIn': isLoggedIn,
        'userInfo': userInfo,
      },
    );
  }

  /// 发送用户信息给H5
  Future<void> sendUserInfoToH5(dynamic webViewController, Map<String, dynamic> userInfo) async {
    await callH5Method(
      webViewController,
      'onUserInfoUpdated',
      params: {'userInfo': userInfo},
    );
  }
}
