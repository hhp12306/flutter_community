/// Tab配置模型
class TabModel {
  final String id;
  final String name;
  final bool visible;
  final int sort;
  final String? route;

  TabModel({
    required this.id,
    required this.name,
    required this.visible,
    required this.sort,
    this.route,
  });

  factory TabModel.fromJson(Map<String, dynamic> json) {
    return TabModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      visible: json['visible'] ?? true,
      sort: json['sort'] ?? 0,
      route: json['route'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'visible': visible,
      'sort': sort,
      'route': route,
    };
  }
}

