import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import '../../services/h5_bridge_service.dart';
import '../../services/native_bridge_service.dart';
import '../../config/app_routes.dart';

/// H5 WebView页面
/// 用于展示帖子、智能、活动详情页等H5页面
/// 支持与H5的双向通信
class H5WebViewPage extends StatefulWidget {
  /// H5页面URL
  final String url;
  
  /// 页面标题（如果H5未提供，则使用此标题）
  final String? title;
  
  /// 额外参数（会通过URL参数或JS注入传递给H5）
  final Map<String, dynamic>? params;

  const H5WebViewPage({
    Key? key,
    required this.url,
    this.title,
    this.params,
  }) : super(key: key);

  @override
  State<H5WebViewPage> createState() => _H5WebViewPageState();
}

class _H5WebViewPageState extends State<H5WebViewPage> {
  late final WebViewController _webViewController;
  final H5BridgeService _h5Bridge = H5BridgeService();
  final NativeBridgeService _nativeBridge = NativeBridgeService();
  
  String? _pageTitle;
  bool _isLoading = true;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _pageTitle = widget.title;
    _initWebView();
  }

  /// 初始化WebView
  void _initWebView() {
    // 构建完整的URL（添加参数）
    String fullUrl = widget.url;
    if (widget.params != null && widget.params!.isNotEmpty) {
      final uri = Uri.parse(fullUrl);
      final queryParams = Map<String, String>.from(uri.queryParameters);
      
      // 添加额外参数
      widget.params!.forEach((key, value) {
        queryParams[key] = value.toString();
      });
      
      fullUrl = uri.replace(queryParameters: queryParams).toString();
    }

    // 创建WebViewController
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _loadingProgress = 0.0;
            });
          },
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100.0;
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });
            
            // 注入JS Bridge
            await _injectJSBridge();
            
            // 获取页面标题
            _updatePageTitle();
            
            // 发送登录状态给H5
            await _sendLoginStatusToH5();
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView加载错误: ${error.description}');
          },
        ),
      )
      // 添加JavaScript Channel，用于接收H5的消息
      ..addJavaScriptChannel(
        'FlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          _handleH5Message(message.message);
        },
      )
      ..loadRequest(Uri.parse(fullUrl));
  }

  /// 注入JS Bridge到H5页面
  Future<void> _injectJSBridge() async {
    final bridgeJS = _h5Bridge.generateBridgeJS();
    await _webViewController.runJavaScript(bridgeJS);
    
    // 注入额外的工具方法
    await _webViewController.runJavaScript('''
      // 提供更多便利方法
      window.FlutterBridge.navigateToPost = function(params) {
        window.FlutterBridge.callFlutter('navigateToPost', params);
      };
      
      window.FlutterBridge.navigateToVideo = function(params) {
        window.FlutterBridge.callFlutter('navigateToVideo', params);
      };
      
      window.FlutterBridge.navigateToActivityDetail = function(params) {
        window.FlutterBridge.callFlutter('navigateToActivityDetail', params);
      };
      
      console.log('FlutterBridge methods injected');
    ''');
  }

  /// 更新页面标题
  Future<void> _updatePageTitle() async {
    try {
      final title = await _webViewController.getTitle();
      if (title != null && title.isNotEmpty && mounted) {
        setState(() {
          _pageTitle = title;
        });
      }
    } catch (e) {
      print('获取页面标题失败: $e');
    }
  }

  /// 发送登录状态给H5
  Future<void> _sendLoginStatusToH5() async {
    try {
      final isLoggedIn = await _nativeBridge.checkLoginStatus();
      Map<String, dynamic>? userInfo;
      
      if (isLoggedIn) {
        userInfo = await _nativeBridge.getUserInfo();
      }
      
      await _h5Bridge.sendLoginStatusToH5(
        _webViewController,
        isLoggedIn,
        userInfo: userInfo,
      );
    } catch (e) {
      print('发送登录状态给H5失败: $e');
    }
  }

  /// 处理H5发送的消息
  void _handleH5Message(String message) {
    try {
      // message已经是JSON字符串，根据消息类型处理
      if (message.contains('navigateToPost')) {
        // H5请求跳转到发帖页
        _handleNavigateToPost();
      } else if (message.contains('navigateToVideo')) {
        // H5请求跳转到视频播放页
        _handleNavigateToVideo(message);
      } else if (message.contains('checkLogin')) {
        // H5检查登录状态
        _handleCheckLogin();
      } else if (message.contains('navigateToNative')) {
        // H5请求跳转到原生页面
        _handleNavigateToNative(message);
      }
    } catch (e) {
      print('处理H5消息失败: $e');
    }
  }

  /// 处理H5请求跳转到发帖页
  void _handleNavigateToPost() async {
    // 检查登录状态
    final isLoggedIn = await _nativeBridge.checkLoginStatus();
    if (!isLoggedIn) {
      final loginResult = await _nativeBridge.navigateToLogin();
      if (!loginResult) {
        return; // 取消登录，不跳转
      }
    }
    
    // 跳转到发帖页
    Get.toNamed(AppRoutes.post);
  }

  /// 处理H5请求跳转到视频播放页
  void _handleNavigateToVideo(String message) {
    // TODO: 解析message获取视频URL等信息，然后跳转
    // Get.toNamed(AppRoutes.videoPlayer, arguments: {'url': videoUrl});
  }

  /// 处理H5检查登录状态
  void _handleCheckLogin() async {
    final isLoggedIn = await _nativeBridge.checkLoginStatus();
    Map<String, dynamic>? userInfo;
    
    if (isLoggedIn) {
      userInfo = await _nativeBridge.getUserInfo();
    }
    
    await _h5Bridge.sendLoginStatusToH5(
      _webViewController,
      isLoggedIn,
      userInfo: userInfo,
    );
  }

  /// 处理H5请求跳转到原生页面
  void _handleNavigateToNative(String message) {
    // TODO: 解析message获取页面名称和参数，然后跳转
    // _nativeBridge.navigateToNativePage(pageName, params: params);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle ?? widget.title ?? '详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 检查是否可以返回上一页
            _webViewController.canGoBack().then((canGoBack) {
              if (canGoBack) {
                _webViewController.goBack();
              } else {
                Navigator.pop(context);
              }
            });
          },
        ),
        // 加载进度条
        bottom: _isLoading
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2.0),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              )
            : null,
      ),
      body: WebViewWidget(controller: _webViewController),
    );
  }
}
