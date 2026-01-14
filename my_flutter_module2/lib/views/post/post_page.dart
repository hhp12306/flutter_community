import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// 发帖页面
/// 支持发文字帖、视频帖、图片帖，支持图文混排，草稿箱功能
class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<File> _selectedImages = [];
  File? _selectedVideo;
  bool _isPublishing = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// 选择图片
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
        });
      }
    } catch (e) {
      // 处理错误
    }
  }

  /// 选择视频
  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null && video.path.isNotEmpty) {
        setState(() {
          _selectedVideo = File(video.path);
        });
      }
    } catch (e) {
      // 处理错误
    }
  }

  /// 拍照
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (image != null && image.path.isNotEmpty) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    } catch (e) {
      // 处理错误
    }
  }

  /// 删除图片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// 删除视频
  void _removeVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  /// 保存草稿
  Future<void> _saveDraft() async {
    // TODO: 保存草稿到本地存储
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('草稿已保存')),
    );
  }

  /// 发布帖子
  Future<void> _publish() async {
    if (_textController.text.trim().isEmpty && 
        _selectedImages.isEmpty && 
        _selectedVideo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入内容或选择图片/视频')),
      );
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      // TODO: 调用发布接口
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('发布成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发布失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发帖'),
        actions: [
          // 保存草稿
          TextButton(
            onPressed: _saveDraft,
            child: const Text('草稿', style: TextStyle(color: Colors.blue)),
          ),
          // 发布
          TextButton(
            onPressed: _isPublishing ? null : _publish,
            child: _isPublishing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('发布', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文本输入框
            TextField(
              controller: _textController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: '分享你的想法...',
                border: InputBorder.none,
              ),
            ),
            
            const SizedBox(height: 16.0),
            
            // 视频预览
            if (_selectedVideo != null)
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Center(
                      child: Icon(Icons.play_circle_filled,
                          color: Colors.white, size: 60),
                    ),
                  ),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: _removeVideo,
                    ),
                  ),
                ],
              ),
            
            // 图片网格
            if (_selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4.0,
                        right: 4.0,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            
            const SizedBox(height: 16.0),
            
            // 工具栏
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 图片
                _buildToolButton(
                  icon: Icons.image,
                  label: '图片',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => _buildImageSourceSheet(),
                    );
                  },
                ),
                // 视频
                _buildToolButton(
                  icon: Icons.videocam,
                  label: '视频',
                  onTap: _pickVideo,
                ),
                // 话题
                _buildToolButton(
                  icon: Icons.tag,
                  label: '话题',
                  onTap: () {
                    // TODO: 选择话题
                  },
                ),
                // 位置
                _buildToolButton(
                  icon: Icons.location_on,
                  label: '位置',
                  onTap: () {
                    // TODO: 选择位置
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建工具栏按钮
  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28, color: Colors.blue),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// 构建图片来源选择底部 sheet
  Widget _buildImageSourceSheet() {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('从相册选择'),
            onTap: () {
              Navigator.pop(context);
              _pickImages();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('拍照'),
            onTap: () {
              Navigator.pop(context);
              _takePhoto();
            },
          ),
        ],
      ),
    );
  }
}

