/// Banner轮播图模型
class BannerModel {
  final String id;
  final String imageUrl;
  final String? linkUrl;
  final String? title;
  final int sort;

  BannerModel({
    required this.id,
    required this.imageUrl,
    this.linkUrl,
    this.title,
    this.sort = 0,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      linkUrl: json['linkUrl'],
      title: json['title'],
      sort: json['sort'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'title': title,
      'sort': sort,
    };
  }
}

