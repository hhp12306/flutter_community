/// 功能组件模型
/// 前后台通过key适配前端组件
class ComponentModel {
  final String id;
  final String key; // 组件key，用于适配前端组件
  final String name; // 组件名称
  final int sort; // 排序
  final bool visible; // 是否显示
  final Map<String, dynamic>? config; // 组件配置数据

  ComponentModel({
    required this.id,
    required this.key,
    required this.name,
    this.sort = 0,
    this.visible = true,
    this.config,
  });

  factory ComponentModel.fromJson(Map<String, dynamic> json) {
    return ComponentModel(
      id: json['id'] ?? '',
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      sort: json['sort'] ?? 0,
      visible: json['visible'] ?? true,
      config: json['config'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'sort': sort,
      'visible': visible,
      'config': config,
    };
  }
}

/// 热门话题模型
class TopicModel {
  final String id;
  final String title;
  final String? imageUrl;
  final int joinCount; // 参与人数
  final String? linkUrl;

  TopicModel({
    required this.id,
    required this.title,
    this.imageUrl,
    this.joinCount = 0,
    this.linkUrl,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'],
      joinCount: json['joinCount'] ?? 0,
      linkUrl: json['linkUrl'],
    );
  }
}

/// 车型圈模型
class CarCircleModel {
  final String id;
  final String name;
  final String? iconUrl;
  final int memberCount; // 成员数
  final int postCount; // 帖子数
  final String? linkUrl;

  CarCircleModel({
    required this.id,
    required this.name,
    this.iconUrl,
    this.memberCount = 0,
    this.postCount = 0,
    this.linkUrl,
  });

  factory CarCircleModel.fromJson(Map<String, dynamic> json) {
    return CarCircleModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'],
      memberCount: json['memberCount'] ?? 0,
      postCount: json['postCount'] ?? 0,
      linkUrl: json['linkUrl'],
    );
  }
}

/// 专题模型
class TopicCollectionModel {
  final String id;
  final String title;
  final String? coverUrl;
  final String? description;
  final int articleCount; // 文章数
  final String? linkUrl;

  TopicCollectionModel({
    required this.id,
    required this.title,
    this.coverUrl,
    this.description,
    this.articleCount = 0,
    this.linkUrl,
  });

  factory TopicCollectionModel.fromJson(Map<String, dynamic> json) {
    return TopicCollectionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      coverUrl: json['coverUrl'],
      description: json['description'],
      articleCount: json['articleCount'] ?? 0,
      linkUrl: json['linkUrl'],
    );
  }
}
