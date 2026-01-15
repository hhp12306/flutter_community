import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/component_model.dart';
import '../../../utils/count_util.dart';

/// 热门话题组件
class HotTopics extends StatelessWidget {
  final List<TopicModel> topics;

  const HotTopics({
    Key? key,
    required this.topics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              '热门话题',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          // 话题列表（横向滚动）
          SizedBox(
            height: 100.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: topics.length,
              itemBuilder: (context, index) {
                return _buildTopicItem(context, topics[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 构建话题项
  Widget _buildTopicItem(BuildContext context, TopicModel topic) {
    return GestureDetector(
      onTap: () {
        // TODO: 跳转到话题详情页
        if (topic.linkUrl != null) {
          // 处理跳转
        }
      },
      child: Container(
        width: 120.0,
        margin: const EdgeInsets.only(right: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Colors.grey[100],
        ),
        child: Stack(
          children: [
            // 背景图片
            if (topic.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: topic.imageUrl!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                  ),
                ),
              ),
            // 内容遮罩
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // 文字内容
            Positioned(
              left: 8.0,
              right: 8.0,
              bottom: 8.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${CountUtil.formatCount(topic.joinCount)}人参与',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10.0,
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
