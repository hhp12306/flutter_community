import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../models/article_model.dart';
import '../../../utils/time_util.dart';
import '../../../utils/count_util.dart';

/// 文章列表组件（瀑布流效果）
class ArticleList extends StatelessWidget {
  final List<ArticleModel> articles;

  const ArticleList({
    Key? key,
    required this.articles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverPadding(
      padding: const EdgeInsets.all(12.0),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2, // 2列瀑布流
        mainAxisSpacing: 12.0,
        crossAxisSpacing: 12.0,
        itemBuilder: (context, index) {
          final article = articles[index];
          return _buildArticleItem(context, article, index);
        },
        childCount: articles.length,
      ),
    );
  }

  /// 构建文章项
  Widget _buildArticleItem(BuildContext context, ArticleModel article, int index) {
    // 根据索引设置不同的图片高度，形成瀑布流效果
    // 偶数索引：200.0，奇数索引：150.0，每3个索引：250.0
    double imageHeight = 200.0;
    if (index % 3 == 0) {
      imageHeight = 250.0; // 每3个文章高度更高
    } else if (index % 2 == 1) {
      imageHeight = 150.0; // 奇数索引高度较低
    }
    
    return GestureDetector(
      onTap: () {
        // TODO: 跳转到详情页
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片（视频封面）
            if (article.imageUrl != null || article.videoUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8.0)),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: article.videoUrl ?? article.imageUrl ?? '',
                      width: double.infinity,
                      height: imageHeight,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: imageHeight,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                    // 视频标识
                    if (article.videoUrl != null)
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            
            // 内容区
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 置顶（精选）标签 + 标题
                  Row(
                    children: [
                      // 置顶/精选标签
                      if (article.isTop)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 2.0,
                          ),
                          margin: const EdgeInsets.only(right: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: const Text(
                            '置顶',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      if (article.isFeatured && !article.isTop)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 2.0,
                          ),
                          margin: const EdgeInsets.only(right: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                          child: const Text(
                            '精选',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                            ),
                          ),
                        ),
                      // 标题
                      Expanded(
                        child: Text(
                          article.title,
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8.0),
                  
                  // 发布人信息
                  Row(
                    children: [
                      // 头像
                      if (article.authorAvatar != null)
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: article.authorAvatar!,
                            width: 24.0,
                            height: 24.0,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 24.0,
                              height: 24.0,
                              color: Colors.grey[300],
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 24.0,
                              height: 24.0,
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 16),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 24.0,
                          height: 24.0,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, size: 16, color: Colors.white),
                        ),
                      
                      const SizedBox(width: 6.0),
                      
                      // 发布人名称
                      Expanded(
                        child: Text(
                          article.authorName,
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.black54,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      // 车型Tag
                      if (article.carTag != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.0,
                          ),
                          margin: const EdgeInsets.only(left: 4.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            article.carTag!,
                            style: const TextStyle(
                              fontSize: 10.0,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 8.0),
                  
                  // 点赞/收藏数
                  Row(
                    children: [
                      // 点赞
                      Icon(
                        article.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16.0,
                        color: article.isLiked ? Colors.red : Colors.grey,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        CountUtil.formatLikeCount(article.likeCount),
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black54,
                        ),
                      ),
                      
                      const SizedBox(width: 16.0),
                      
                      // 收藏
                      Icon(
                        article.isCollected ? Icons.bookmark : Icons.bookmark_border,
                        size: 16.0,
                        color: article.isCollected ? Colors.orange : Colors.grey,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        CountUtil.formatCount(article.collectCount),
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black54,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // 发布时间
                      Text(
                        TimeUtil.formatTimestamp(article.publishTime),
                        style: const TextStyle(
                          fontSize: 10.0,
                          color: Colors.black38,
                        ),
                      ),
                    ],
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

