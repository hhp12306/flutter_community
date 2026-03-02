import 'package:flutter/material.dart';

/// 品牌5活动页（样式五）
class ActivityBrand5Page extends StatelessWidget {
  const ActivityBrand5Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: Colors.teal.shade700,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('品牌5 活动', style: TextStyle(fontSize: 16)),
              centerTitle: true,
            ),
          ),
        ],
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('品牌5 活动 ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('描述文案', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.teal.shade700),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
