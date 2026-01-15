import 'package:flutter/material.dart';

/// 直播页面
class LivePage extends StatefulWidget {
  const LivePage({Key? key}) : super(key: key);

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持页面状态

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于保持页面状态
    return Center(
      child: const Text('直播页面', style: TextStyle(fontSize: 18.0)),
    );
  }
}

