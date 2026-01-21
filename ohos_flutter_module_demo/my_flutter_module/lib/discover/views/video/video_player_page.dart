import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../../viewmodels/video_player_viewmodel.dart';

/// 视频播放页面（MVVM 架构）
/// 支持视频缓存播放、上下手势滑动切换
class VideoPlayerPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // 使用 Get.put 创建 ViewModel，页面销毁时自动清理
    final viewModel = Get.put(VideoPlayerViewModel());
    
    // 初始化视频列表
    viewModel.initVideos(videoUrl, videoList);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() => viewModel.hasMultipleVideos
          ? _buildVerticalPageView(viewModel) // 多个视频时使用垂直滑动切换
          : _buildSingleVideo(viewModel)), // 单个视频直接播放
    );
  }

  /// 构建垂直滑动视图（上下滑动切换视频）
  Widget _buildVerticalPageView(VideoPlayerViewModel viewModel) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      onPageChanged: (index) => viewModel.switchToVideo(index),
      itemCount: viewModel.videoUrls.length,
      itemBuilder: (context, index) {
        return _buildVideoPlayer(viewModel, index == viewModel.currentIndex);
      },
    );
  }

  /// 构建单个视频播放器
  Widget _buildSingleVideo(VideoPlayerViewModel viewModel) {
    return _buildVideoPlayer(viewModel, true);
  }

  /// 构建视频播放器
  Widget _buildVideoPlayer(VideoPlayerViewModel viewModel, bool isActive) {
    if (!isActive || !viewModel.isInitialized || viewModel.videoPlayerController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(
        child: Text(
          viewModel.errorMessage!,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () => viewModel.togglePlayPause(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频播放器
          Center(
            child: AspectRatio(
              aspectRatio: viewModel.videoPlayerController!.value.aspectRatio,
              child: VideoPlayer(viewModel.videoPlayerController!),
            ),
          ),
          
          // 播放/暂停按钮
          Obx(() => !viewModel.isPlaying
              ? Center(
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
                )
              : const SizedBox.shrink()),
          
          // 顶部标题栏和返回按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(Get.context!),
                  ),
                  if (videoTitle != null)
                    Expanded(
                      child: Text(
                        videoTitle!,
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
