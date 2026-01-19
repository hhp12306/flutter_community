import 'package:flutter/material.dart';

/// 圈子页面
class CirclePage extends StatefulWidget {
  const CirclePage({Key? key}) : super(key: key);

  @override
  State<CirclePage> createState() => _CirclePageState();
}

class _CirclePageState extends State<CirclePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持页面状态

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于保持页面状态
    return const Center(
      child: Text('圈子页面', style: TextStyle(fontSize: 18.0)),
    );
  }
}

