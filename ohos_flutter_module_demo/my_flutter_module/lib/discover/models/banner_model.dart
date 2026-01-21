/// Banner轮播图模型
class BannerModel {
  final String id;
  final String imageUrl;
  final String? linkUrl;
  final String? title;
  final int sort;
  final int? themeStyle; // 主题样式：1为黑色，2为白色

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
    this.title,
    this.sort = 0,
    this.themeStyle,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      linkUrl: json['linkUrl'],
      title: json['title'],
      sort: json['sort'] ?? 0,
      themeStyle: json['themeStyle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'title': title,
      'sort': sort,
      'themeStyle': themeStyle,
    };
  }
}

