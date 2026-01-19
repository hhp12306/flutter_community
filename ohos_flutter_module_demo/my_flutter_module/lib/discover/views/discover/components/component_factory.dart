import 'package:flutter/material.dart';
import '../../../models/component_model.dart';
import 'hot_topics.dart';
import 'car_circle_list.dart';
import 'topic_collection.dart';

/// 组件工厂
/// 根据key动态创建组件，前后台通过key适配
class ComponentFactory {
  /// 根据组件模型创建Widget
  static Widget? createComponent(ComponentModel component) {
    switch (component.key) {
      case 'hot_topics':
        // 热门话题
        if (component.config != null && component.config!['topics'] != null) {
          final topicsJson = component.config!['topics'] as List;
          final topics = topicsJson
              .map((json) => TopicModel.fromJson(json as Map<String, dynamic>))
              .toList();
          return HotTopics(topics: topics);
        }
        break;
        
      case 'car_circle_list':
        // 车型圈列表
        if (component.config != null && component.config!['circles'] != null) {
          final circlesJson = component.config!['circles'] as List;
          final circles = circlesJson
              .map((json) => CarCircleModel.fromJson(json as Map<String, dynamic>))
              .toList();
          return CarCircleList(circles: circles);
        }
        break;
        
      case 'topic_collection':
        // 专题合集
        if (component.config != null && component.config!['collections'] != null) {
          final collectionsJson = component.config!['collections'] as List;
          final collections = collectionsJson
              .map((json) => TopicCollectionModel.fromJson(json as Map<String, dynamic>))
              .toList();
          return TopicCollection(
            collections: collections,
            title: component.config!['title'] as String?,
          );
        }
        break;
        
      case 'topic':
        // 单个专题（可以添加多个）
        if (component.config != null) {
          final collection = TopicCollectionModel.fromJson(component.config!);
          return TopicCollection(
            collections: [collection],
            title: component.name,
          );
        }
        break;
    }
    
    return null;
  }
}
