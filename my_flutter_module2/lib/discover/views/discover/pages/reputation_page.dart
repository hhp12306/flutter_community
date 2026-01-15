import 'package:flutter/material.dart';

/// 口碑页面
class ReputationPage extends StatefulWidget {
  const ReputationPage({Key? key}) : super(key: key);

  @override
  State<ReputationPage> createState() => _ReputationPageState();
}

class _ReputationPageState extends State<ReputationPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // 保持页面状态

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用，用于保持页面状态
    return Center(
      child: const Text('口碑页面', style: TextStyle(fontSize: 18.0)),
    );
  }
}

