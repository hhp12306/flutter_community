import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 视频播放页面
/// 支持视频缓存播放、上下手势滑动切换
class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String? videoTitle;
  final List<String>? videoList; // 视频列表，用于上下滑动切换

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    this.videoTitle,
    this.videoList,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _videoPlayerController;
  PageController? _pageController;
  
  List<String> _videoUrls = [];
  int _currentIndex = 0;
  bool _isInitialized = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  /// 初始化视频
  void _initVideo() {
    // 如果有视频列表，使用列表；否则只播放当前视频
    if (widget.videoList != null && widget.videoList!.isNotEmpty) {
      _videoUrls = widget.videoList!;
      _currentIndex = _videoUrls.indexOf(widget.videoUrl);
      if (_currentIndex == -1) {
        _currentIndex = 0;
        _videoUrls.insert(0, widget.videoUrl);
      }
    } else {
      _videoUrls = [widget.videoUrl];
      _currentIndex = 0;
    }

    // 创建PageController用于上下滑动切换
    _pageController = PageController(initialPage: _currentIndex);
    
    _loadVideo(_currentIndex);
  }

  /// 加载视频
  Future<void> _loadVideo(int index) async {
    if (index < 0 || index >= _videoUrls.length) {
      return;
    }

    // 释放之前的控制器
    _videoPlayerController?.dispose();

    setState(() {
      _isInitialized = false;
      _isPlaying = false;
    });

    try {
      // 创建新的视频控制器
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(_videoUrls[index]),
      );

      // 监听播放状态
      _videoPlayerController!.addListener(_videoListener);

      await _videoPlayerController!.initialize();

      if (mounted) {
        // 自动播放
        await _videoPlayerController!.play();
        
        setState(() {
          _isInitialized = true;
          _isPlaying = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('视频加载失败: $e')),
        );
      }
    }
  }

  /// 视频状态监听器
  void _videoListener() {
    if (_videoPlayerController != null && mounted) {
      setState(() {
        _isPlaying = _videoPlayerController!.value.isPlaying;
      });
    }
  }

  /// 切换视频
  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      _loadVideo(index);
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.removeListener(_videoListener);
    _videoPlayerController?.dispose();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _videoUrls.length > 1
          ? _buildVerticalPageView() // 多个视频时使用垂直滑动切换
          : _buildSingleVideo(), // 单个视频直接播放
    );
  }

  /// 构建垂直滑动视图（上下滑动切换视频）
  Widget _buildVerticalPageView() {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      onPageChanged: _onPageChanged,
      itemCount: _videoUrls.length,
      itemBuilder: (context, index) {
        return _buildVideoPlayer(index == _currentIndex);
      },
    );
  }

  /// 构建单个视频播放器
  Widget _buildSingleVideo() {
    return _buildVideoPlayer(true);
  }

  /// 构建视频播放器
  Widget _buildVideoPlayer(bool isActive) {
    if (!isActive || !_isInitialized || _videoPlayerController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return GestureDetector(
      onTap: () {
        // 点击播放/暂停
        if (_videoPlayerController!.value.isPlaying) {
          _videoPlayerController!.pause();
        } else {
          _videoPlayerController!.play();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频播放器
          Center(
            child: AspectRatio(
              aspectRatio: _videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(_videoPlayerController!),
            ),
          ),
          
          // 播放/暂停按钮
          if (!_isPlaying)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          
          // 顶部标题栏和返回按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  if (widget.videoTitle != null)
                    Expanded(
                      child: Text(
                        widget.videoTitle!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

