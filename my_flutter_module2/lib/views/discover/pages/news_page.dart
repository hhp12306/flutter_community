import 'package:flutter/material.dart';

/// 资讯页面
class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持页面状态

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于保持页面状态
    return const Center(
      child: Text('资讯页面', style: TextStyle(fontSize: 18.0)),
    );
  }
}

