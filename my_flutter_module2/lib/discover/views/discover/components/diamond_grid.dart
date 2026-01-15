import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/diamond_model.dart';

/// 金刚区组件
/// 一行5个图标，最多支持2行，可左右滑动多屏显示
class DiamondGrid extends StatelessWidget {
  final List<DiamondModel> diamonds;

  const DiamondGrid({
    Key? key,
    required this.diamonds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (diamonds.isEmpty) {
      return const SizedBox.shrink();
    }

    // 过滤可见的图标
    final visibleDiamonds = diamonds.where((d) => d.visible).toList();
    if (visibleDiamonds.isEmpty) {
      return const SizedBox.shrink();
    }

    // 计算需要多少页（每页最多10个：2行×5列）
    final pageCount = (visibleDiamonds.length / 10).ceil();
    
    // 如果只有一页，直接显示；否则使用PageView滑动
    if (pageCount == 1) {
      return _buildGrid(context, visibleDiamonds);
    } else {
      return SizedBox(
        height: 160.0, // 2行的高度
        child: PageView.builder(
          itemCount: pageCount,
          itemBuilder: (context, pageIndex) {
            final startIndex = pageIndex * 10;
            final endIndex = (startIndex + 10).clamp(0, visibleDiamonds.length);
            final pageDiamonds = visibleDiamonds.sublist(startIndex, endIndex);
            return _buildGrid(context, pageDiamonds);
          },
        ),
      );
    }
  }

  /// 构建网格
  Widget _buildGrid(BuildContext context, List<DiamondModel> diamonds) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5, // 一行5个
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
          childAspectRatio: 0.8,
        ),
        itemCount: diamonds.length,
        itemBuilder: (context, index) {
          final diamond = diamonds[index];
          return _buildDiamondItem(context, diamond);
        },
      ),
    );
  }

  /// 构建单个图标项
  Widget _buildDiamondItem(BuildContext context, DiamondModel diamond) {
    return GestureDetector(
      onTap: () {
        // TODO: 跳转到对应页面
        if (diamond.linkUrl != null) {
          // 处理跳转
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 图标
          Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: diamond.iconUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.error, size: 24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4.0),
          // 名称（最多2个字）
          Text(
            diamond.name.length > 2 ? diamond.name.substring(0, 2) : diamond.name,
            style: const TextStyle(
              fontSize: 12.0,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

