import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/component_model.dart';
import '../../../utils/count_util.dart';

/// 专题合集组件
/// 可以包含多个专题
class TopicCollection extends StatelessWidget {
  final List<TopicCollectionModel> collections;
  final String? title; // 自定义标题

  const TopicCollection({
    Key? key,
    required this.collections,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          // 专题列表（横向滚动）
          SizedBox(
            height: 140.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: collections.length,
              itemBuilder: (context, index) {
                return _buildCollectionItem(context, collections[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建专题项
  Widget _buildCollectionItem(BuildContext context, TopicCollectionModel collection) {
    return GestureDetector(
      onTap: () {
        // TODO: 跳转到专题详情页
        if (collection.linkUrl != null) {
          // 处理跳转
        }
      },
      child: Container(
        width: 160.0,
        margin: const EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[100],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                child: collection.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: collection.coverUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image, size: 32),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 32),
                      ),
              ),
            ),
            // 文字信息
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.title,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (collection.description != null) ...[
                    const SizedBox(height: 4.0),
                    Text(
                      collection.description!,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 4.0),
                  Text(
                    '${CountUtil.formatCount(collection.articleCount)}篇文章',
                    style: TextStyle(
                      fontSize: 10.0,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
