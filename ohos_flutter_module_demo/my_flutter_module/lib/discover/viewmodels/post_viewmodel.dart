import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/base/base_viewmodel.dart';

/// 发帖页面 ViewModel（MVVM 架构 - 新架构版本）
/// 负责管理发帖页面的状态和业务逻辑
class PostViewModel extends BaseViewModel {
  final ImagePicker _imagePicker = ImagePicker();
  
  // 响应式变量
  final _textContent = ''.obs;
  final _selectedImages = <File>[].obs;
  final _selectedVideo = Rx<File?>(null);
  
  // Getters
  String get textContent => _textContent.value;
  List<File> get selectedImages => _selectedImages;
  File? get selectedVideo => _selectedVideo.value;
  bool get isPublishing => isLoading; // 使用基类的 isLoading
  bool get isSavingDraft => isLoading; // 使用基类的 isLoading
  bool get hasContent => _textContent.value.trim().isNotEmpty || 
                        _selectedImages.isNotEmpty || 
                        _selectedVideo.value != null;
  
  /// 更新文本内容
  void updateTextContent(String text) {
    _textContent.value = text;
  }
  
  /// 选择图片（从相册）
  Future<void> pickImages() async {
    await execute(() async {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
      }
    }, showLoading: false);
  }
  
  /// 选择视频（从相册）
  Future<void> pickVideo() async {
    await execute(() async {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
      );
      if (video != null && video.path.isNotEmpty) {
        _selectedVideo.value = File(video.path);
        // 选择视频时清空图片
        _selectedImages.clear();
      }
    }, showLoading: false);
  }
  
  /// 拍照
  Future<void> takePhoto() async {
    await execute(() async {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
      );
      if (image != null && image.path.isNotEmpty) {
        _selectedImages.add(File(image.path));
      }
    }, showLoading: false);
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
    
    await execute(() async {
      // TODO: 保存草稿到本地存储
      await Future.delayed(const Duration(milliseconds: 500));
      Get.snackbar('成功', '草稿已保存', snackPosition: SnackPosition.BOTTOM);
    });
  }
  
  /// 发布帖子
  Future<void> publish() async {
    if (!hasContent) {
      Get.snackbar('提示', '请输入内容或选择图片/视频');
      return;
    }
    
    await execute(() async {
      // TODO: 调用发布接口
      await Future.delayed(const Duration(seconds: 2));
      
      // 发布成功后返回上一页
      Get.back();
      Get.snackbar('成功', '发布成功', snackPosition: SnackPosition.BOTTOM);
      
      // 清空内容
      clearContent();
    });
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
