import 'package:flutter/material.dart';

/// 品牌4活动页（样式四）
class ActivityBrand4Page extends StatelessWidget {
  const ActivityBrand4Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purple.shade300,
        title: const Text('品牌4 · 活动'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.purple.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Banner 区域',
                    style: TextStyle(
                      color: Colors.purple.shade900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...List.generate(4, (i) => _buildSection(i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  color: Colors.purple.shade200,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 120,
                  color: Colors.purple.shade100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
