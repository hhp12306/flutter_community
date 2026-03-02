import 'package:flutter/material.dart';

/// 品牌2活动页（样式二）
class ActivityBrand2Page extends StatelessWidget {
  const ActivityBrand2Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.campaign, size: 48, color: Colors.orange.shade700),
                    const SizedBox(height: 12),
                    Text(
                      '品牌2 活动中心',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(3, (i) => _buildListItem(i)),
          ],
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.orange.shade200),
        title: Text('活动 ${index + 1}'),
        subtitle: const Text('品牌2专属'),
      ),
    );
  }
}
