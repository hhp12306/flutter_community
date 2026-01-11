/// 金刚区图标模型
class DiamondModel {
  final String id;
  final String name;
  final String iconUrl;
  final String? linkUrl;
  final bool visible;
  final int sort;

  DiamondModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    this.linkUrl,
    this.visible = true,
    this.sort = 0,
  });

  factory DiamondModel.fromJson(Map<String, dynamic> json) {
    return DiamondModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      linkUrl: json['linkUrl'],
      visible: json['visible'] ?? true,
      sort: json['sort'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'linkUrl': linkUrl,
      'visible': visible,
      'sort': sort,
    };
  }
}

