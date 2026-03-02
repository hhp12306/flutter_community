import 'package:flutter/material.dart';

/// 品牌3活动页（样式三）
class ActivityBrand3Page extends StatelessWidget {
  const ActivityBrand3Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade50, Colors.green.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '品牌3',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.filter_list),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: List.generate(4, (i) => _buildGridCard(i)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridCard(int index) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Text('活动${index + 1}', style: TextStyle(color: Colors.green.shade800)),
      ),
    );
  }
}
