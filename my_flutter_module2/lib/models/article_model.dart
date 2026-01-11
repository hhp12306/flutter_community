/// 文章/资讯模型
class ArticleModel {
  final String id;
  final String title;
  final String? imageUrl;
  final String? videoUrl;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String? carTag; // 车型标签
  final int likeCount;
  final int commentCount;
  final int collectCount;
  final bool isTop; // 是否置顶
  final bool isFeatured; // 是否精选
  final bool isLiked; // 是否已点赞
  final bool isCollected; // 是否已收藏
  final int publishTime;
  final String? content;
  final List<String>? images; // 图片列表

  ArticleModel({
    required this.id,
    required this.title,
    this.imageUrl,
    this.videoUrl,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.carTag,
    this.likeCount = 0,
    this.commentCount = 0,
    this.collectCount = 0,
    this.isTop = false,
    this.isFeatured = false,
    this.isLiked = false,
    this.isCollected = false,
    required this.publishTime,
    this.content,
    this.images,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'],
      videoUrl: json['videoUrl'],
      authorId: json['authorId'] ?? '',
      authorName: json['authorName'] ?? '',
      authorAvatar: json['authorAvatar'],
      carTag: json['carTag'],
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      collectCount: json['collectCount'] ?? 0,
      isTop: json['isTop'] ?? false,
      isFeatured: json['isFeatured'] ?? false,
      isLiked: json['isLiked'] ?? false,
      isCollected: json['isCollected'] ?? false,
      publishTime: json['publishTime'] ?? 0,
      content: json['content'],
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'carTag': carTag,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'collectCount': collectCount,
      'isTop': isTop,
      'isFeatured': isFeatured,
      'isLiked': isLiked,
      'isCollected': isCollected,
      'publishTime': publishTime,
      'content': content,
      'images': images,
    };
  }
}

