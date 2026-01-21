import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/post_controller.dart';

/// 发帖页面（MVVM 架构）
/// 支持发文字帖、视频帖、图片帖，支持图文混排，草稿箱功能
class PostPage extends StatelessWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 使用 Get.put 创建 Controller，页面销毁时自动清理
    final controller = Get.put(PostController());
    final TextEditingController textController = TextEditingController();
    
    // 监听文本变化，更新 Controller
    textController.addListener(() {
      controller.updateTextContent(textController.text);
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('发帖'),
        actions: [
          // 保存草稿
          Obx(() => TextButton(
            onPressed: controller.isSavingDraft ? null : () => controller.saveDraft(),
            child: controller.isSavingDraft
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('草稿', style: TextStyle(color: Colors.blue)),
          )),
          // 发布
          Obx(() => TextButton(
            onPressed: controller.isPublishing ? null : () => controller.publish(),
            child: controller.isPublishing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('发布', style: TextStyle(color: Colors.blue)),
          )),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 文本输入框
            TextField(
              controller: textController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '分享你的想法...',
                border: InputBorder.none,
              ),
            ),
            
            const SizedBox(height: 16.0),
            
            // 视频预览
            Obx(() => controller.selectedVideo != null
                ? Stack(
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
                          onPressed: () => controller.removeVideo(),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink()),
            
            // 图片网格
            Obx(() => controller.selectedImages.isNotEmpty
                ? GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    itemCount: controller.selectedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.file(
                              controller.selectedImages[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 4.0,
                            right: 4.0,
                            child: GestureDetector(
                              onTap: () => controller.removeImage(index),
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
                  )
                : const SizedBox.shrink()),
            
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
                      builder: (context) => _buildImageSourceSheet(controller),
                    );
                  },
                ),
                // 视频
                _buildToolButton(
                  icon: Icons.videocam,
                  label: '视频',
                  onTap: () => controller.pickVideo(),
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
  Widget _buildImageSourceSheet(PostController controller) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('从相册选择'),
            onTap: () {
              Navigator.pop(Get.context!);
              controller.pickImages();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('拍照'),
            onTap: () {
              Navigator.pop(Get.context!);
              controller.takePhoto();
            },
          ),
        ],
      ),
    );
  }
}
