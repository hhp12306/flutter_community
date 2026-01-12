import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../models/article_model.dart';
import '../../../utils/time_util.dart';
import '../../common/common_components.dart';

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
            // 图片（视频封面）- 使用通用组件
            if (article.imageUrl != null || article.videoUrl != null)
              ImageDisplay(
                imageUrl: article.imageUrl,
                videoUrl: article.videoUrl,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
                borderRadius: 8.0,
                showVideoIcon: true,
                enablePreview: true,
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
                  
                  // 发布人信息 - 使用通用组件（带关注按钮）
                  UserInfo(
                    avatarUrl: article.authorAvatar,
                    userName: article.authorName,
                    tag: article.carTag,
                    authorId: article.authorId,
                    avatarSize: 24.0,
                    fontSize: 12.0,
                    showFollowButton: true, // 显示关注按钮
                    isFollowed: article.isFollowed,
                    onFollowChanged: (isFollowed) {
                      // TODO: 更新文章关注状态
                      // 这里可以更新本地状态或调用API
                    },
                  ),
                  
                  const SizedBox(height: 8.0),
                  
                  // 点赞/收藏数 - 使用通用组件
                  Row(
                    children: [
                      // 点赞按钮
                      LikeButton(
                        isLiked: article.isLiked,
                        likeCount: article.likeCount,
                        iconSize: 16.0,
                        fontSize: 12.0,
                        onLikeChanged: (isLiked) {
                          // TODO: 更新文章点赞状态
                        },
                      ),
                      
                      const SizedBox(width: 16.0),
                      
                      // 收藏按钮
                      CollectButton(
                        isCollected: article.isCollected,
                        collectCount: article.collectCount,
                        iconSize: 16.0,
                        fontSize: 12.0,
                        onCollectChanged: (isCollected) {
                          // TODO: 更新文章收藏状态
                        },
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

