import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/component_model.dart';
import '../../../utils/count_util.dart';

/// 车型圈列表组件
class CarCircleList extends StatelessWidget {
  final List<CarCircleModel> circles;

  const CarCircleList({
    Key? key,
    required this.circles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (circles.isEmpty) {
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
              '车型圈',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          // 车型圈列表
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: circles.length,
            itemBuilder: (context, index) {
              return _buildCircleItem(context, circles[index]);
            },
          ),
        ],
      ),
    );
  }

  /// 构建车型圈项
  Widget _buildCircleItem(BuildContext context, CarCircleModel circle) {
    return GestureDetector(
      onTap: () {
        // TODO: 跳转到车型圈详情页
        if (circle.linkUrl != null) {
          // 处理跳转
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // 图标
            Container(
              width: 50.0,
              height: 50.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[200],
              ),
              child: circle.iconUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: CachedNetworkImage(
                        imageUrl: circle.iconUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.directions_car, size: 24),
                        ),
                      ),
                    )
                  : const Icon(Icons.directions_car, size: 24, color: Colors.grey),
            ),
            const SizedBox(width: 12.0),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    circle.name,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      Text(
                        '${CountUtil.formatCount(circle.memberCount)}成员',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Text(
                        '${CountUtil.formatCount(circle.postCount)}帖子',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 箭头
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
