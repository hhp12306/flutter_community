import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

/// 视频播放页面 ViewModel（MVVM 架构）
/// 负责管理视频播放页面的状态和业务逻辑
class VideoPlayerViewModel extends GetxController {
  // 响应式变量
  final _videoUrls = <String>[].obs;
  final _currentIndex = 0.obs;
  final _isInitialized = false.obs;
  final _isPlaying = false.obs;
  final _videoPlayerController = Rx<VideoPlayerController?>(null);
  final _errorMessage = Rx<String?>(null);
  
  // Getters
  List<String> get videoUrls => _videoUrls;
  int get currentIndex => _currentIndex.value;
  bool get isInitialized => _isInitialized.value;
  bool get isPlaying => _isPlaying.value;
  VideoPlayerController? get videoPlayerController => _videoPlayerController.value;
  String? get errorMessage => _errorMessage.value;
  bool get hasMultipleVideos => _videoUrls.length > 1;
  
  /// 初始化视频列表
  void initVideos(String videoUrl, List<String>? videoList) {
    // 如果有视频列表，使用列表；否则只播放当前视频
    if (videoList != null && videoList.isNotEmpty) {
      _videoUrls.value = List.from(videoList);
      final index = _videoUrls.indexOf(videoUrl);
      if (index != -1) {
        _currentIndex.value = index;
      } else {
        _currentIndex.value = 0;
        _videoUrls.insert(0, videoUrl);
      }
    } else {
      _videoUrls.value = [videoUrl];
      _currentIndex.value = 0;
    }
    
    // 加载当前视频
    _loadVideo(_currentIndex.value);
  }
  
  /// 加载视频
  Future<void> _loadVideo(int index) async {
    if (index < 0 || index >= _videoUrls.length) {
      return;
    }
    
    // 释放之前的控制器
    await _disposeController();
    
    _isInitialized.value = false;
    _isPlaying.value = false;
    _errorMessage.value = null;
    
    try {
      // 创建新的视频控制器
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(_videoUrls[index]),
      );
      
      // 监听播放状态
      controller.addListener(_videoListener);
      
      await controller.initialize();
      
      _videoPlayerController.value = controller;
      _isInitialized.value = true;
      
      // 自动播放
      await controller.play();
      _isPlaying.value = true;
    } catch (e) {
      _errorMessage.value = '视频加载失败: $e';
      Get.snackbar('错误', _errorMessage.value!);
    }
  }
  
  /// 视频状态监听器
  void _videoListener() {
    final controller = _videoPlayerController.value;
    if (controller != null) {
      _isPlaying.value = controller.value.isPlaying;
    }
  }
  
  /// 切换视频
  void switchToVideo(int index) {
    if (_currentIndex.value != index && index >= 0 && index < _videoUrls.length) {
      _currentIndex.value = index;
      _loadVideo(index);
    }
  }
  
  /// 播放/暂停
  Future<void> togglePlayPause() async {
    final controller = _videoPlayerController.value;
    if (controller != null) {
      if (controller.value.isPlaying) {
        await controller.pause();
      } else {
        await controller.play();
      }
    }
  }
  
  /// 释放控制器
  Future<void> _disposeController() async {
    final controller = _videoPlayerController.value;
    if (controller != null) {
      controller.removeListener(_videoListener);
      await controller.dispose();
      _videoPlayerController.value = null;
    }
  }
  
  @override
  void onClose() {
    _disposeController();
    super.onClose();
  }
}
