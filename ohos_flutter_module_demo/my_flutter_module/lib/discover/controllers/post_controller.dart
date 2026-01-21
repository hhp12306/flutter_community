import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// 发帖页面 Controller（MVC 架构）
/// 负责处理用户输入，协调 Model 和 View
class PostController extends GetxController {
  final ImagePicker _imagePicker = ImagePicker();
  
  // 响应式变量
  final _textContent = ''.obs;
  final _selectedImages = <File>[].obs;
  final _selectedVideo = Rx<File?>(null);
  final _isPublishing = false.obs;
  final _isSavingDraft = false.obs;
  
  // Getters
  String get textContent => _textContent.value;
  List<File> get selectedImages => _selectedImages;
  File? get selectedVideo => _selectedVideo.value;
  bool get isPublishing => _isPublishing.value;
  bool get isSavingDraft => _isSavingDraft.value;
  bool get hasContent => _textContent.value.trim().isNotEmpty || 
                        _selectedImages.isNotEmpty || 
                        _selectedVideo.value != null;
  
  /// 更新文本内容
  void updateTextContent(String text) {
    _textContent.value = text;
  }
  
  /// 选择图片（从相册）
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
      }
    } catch (e) {
      // 处理错误
      Get.snackbar('错误', '选择图片失败: $e');
    }
  }
  
  /// 选择视频（从相册）
  Future<void> pickVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null && video.path.isNotEmpty) {
        _selectedVideo.value = File(video.path);
        // 选择视频时清空图片
        _selectedImages.clear();
      }
    } catch (e) {
      Get.snackbar('错误', '选择视频失败: $e');
    }
  }
  
  /// 拍照
  Future<void> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (image != null && image.path.isNotEmpty) {
        _selectedImages.add(File(image.path));
      }
    } catch (e) {
      Get.snackbar('错误', '拍照失败: $e');
    }
  }
  
  /// 删除图片
  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
    }
  }
  
  /// 删除视频
  void removeVideo() {
    _selectedVideo.value = null;
  }
  
  /// 保存草稿
  Future<void> saveDraft() async {
    if (!hasContent) {
      Get.snackbar('提示', '没有内容可保存');
      return;
    }
    
    _isSavingDraft.value = true;
    
    try {
      // TODO: 保存草稿到本地存储
      await Future.delayed(const Duration(milliseconds: 500));
      
      Get.snackbar('成功', '草稿已保存', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('错误', '保存草稿失败: $e');
    } finally {
      _isSavingDraft.value = false;
    }
  }
  
  /// 发布帖子
  Future<void> publish() async {
    if (!hasContent) {
      Get.snackbar('提示', '请输入内容或选择图片/视频');
      return;
    }
    
    _isPublishing.value = true;
    
    try {
      // TODO: 调用发布接口
      await Future.delayed(const Duration(seconds: 2));
      
      // 发布成功后返回上一页
      Get.back();
      Get.snackbar('成功', '发布成功', snackPosition: SnackPosition.BOTTOM);
      
      // 清空内容
      clearContent();
    } catch (e) {
      Get.snackbar('错误', '发布失败: $e');
    } finally {
      _isPublishing.value = false;
    }
  }
  
  /// 清空内容
  void clearContent() {
    _textContent.value = '';
    _selectedImages.clear();
    _selectedVideo.value = null;
  }
  
  @override
  void onClose() {
    clearContent();
    super.onClose();
  }
}
