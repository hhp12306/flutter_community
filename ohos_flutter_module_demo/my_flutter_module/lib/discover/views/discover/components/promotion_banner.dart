import 'package:flutter/material.dart';

/// 促销活动Banner组件
/// 支持渐变背景、大标题、丝带横幅、装饰元素等
class PromotionBanner extends StatelessWidget {
  final String? mainTitle; // 主标题（如"朝活跃大比拼"）
  final String? subTitle; // 副标题（如"专享狂欢季"）
  final String? ribbonText; // 丝带文字（如"你的每一次出行,都是通往惊喜的旅程"）
  final String? imageUrl; // 背景图片（可选）
  final VoidCallback? onTap; // 点击回调

  const PromotionBanner({
    Key? key,
    this.mainTitle,
    this.subTitle,
    this.ribbonText,
    this.imageUrl,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 220.0,
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 渐变背景
              _buildGradientBackground(),
              
              // 城市天际线剪影（底部）
              _buildCitySkyline(),
              
              // 装饰元素（奖励物品气泡）
              _buildDecorationElements(),
              
              // 内容层
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建渐变背景
  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFF8C42), // 橙色
            const Color(0xFFFFB347), // 浅橙色
            const Color(0xFFFFD700), // 黄色
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  /// 构建城市天际线剪影
  Widget _buildCitySkyline() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: CustomPaint(
        size: const Size(double.infinity, 40.0),
        painter: _CitySkylinePainter(),
      ),
    );
  }

  /// 构建装饰元素（奖励物品气泡）
  Widget _buildDecorationElements() {
    return Stack(
      children: [
        // 右上角：黑色马克杯
        Positioned(
          top: 20.0,
          right: 30.0,
          child: _buildBubble(
            child: Container(
              width: 40.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Center(
                child: Text(
                  'BYD\n2024',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 8.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        
        // 左侧：矩形礼包
        Positioned(
          top: 50.0,
          left: 20.0,
          child: _buildBubble(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 30.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Center(
                    child: Text(
                      'BYD\n2024',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),
                Container(
                  width: 30.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Center(
                    child: Text(
                      'BYD\n2024',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // 中心：透明容器
        Positioned(
          top: 80.0,
          left: 120.0,
          child: _buildBubble(
            child: Container(
              width: 25.0,
              height: 35.0,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                border: Border.all(color: Colors.white, width: 1.0),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Container(
                margin: const EdgeInsets.only(top: 20.0),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(4.0),
                    bottomRight: Radius.circular(4.0),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // 右下角：绿色盒子
        Positioned(
          bottom: 60.0,
          right: 40.0,
          child: _buildBubble(
            child: Container(
              width: 35.0,
              height: 30.0,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4.0),
                border: Border.all(color: Colors.white, width: 1.0),
              ),
            ),
          ),
        ),
        
          // 底部中心：宝箱
        Positioned(
          bottom: 30.0,
          left: 150.0,
          child: _buildBubble(
            child: Container(
              width: 50.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: const Color(0xFF8B4513),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Stack(
                children: [
                  // 宝箱盖子
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 15.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF654321),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(4.0),
                          topRight: Radius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  // 金币和红包装饰
                  Positioned(
                    bottom: 5.0,
                    left: 5.0,
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建气泡容器
  Widget _buildBubble({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }

  /// 构建内容层
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 主标题（"朝活跃大比拼"）
          if (mainTitle != null)
            _buildMainTitle(mainTitle!),
          
          const SizedBox(height: 8.0),
          
          // 副标题（"专享狂欢季"）
          if (subTitle != null)
            _buildSubTitle(subTitle!),
          
          const SizedBox(height: 20.0),
          
          // 丝带横幅
          if (ribbonText != null)
            _buildRibbon(ribbonText!),
        ],
      ),
    );
  }

  /// 构建主标题
  Widget _buildMainTitle(String title) {
    // 将标题拆分为字符，第一个字符（"朝"）特别大
    final chars = title.split('');
    if (chars.isEmpty) return const SizedBox.shrink();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 第一个字符特别大
        Text(
          chars[0],
          style: const TextStyle(
            fontSize: 48.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.0,
            shadows: [
              Shadow(
                color: Colors.black26,
                offset: Offset(2, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        // 其余字符正常大小
        if (chars.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              chars.sublist(1).join(''),
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.0,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 构建副标题
  Widget _buildSubTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black26,
            offset: Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
    );
  }

  /// 构建丝带横幅
  Widget _buildRibbon(String text) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth - 40.0, 40.0),
          painter: _RibbonPainter(text: text),
        );
      },
    );
  }
}

/// 城市天际线绘制器
class _CitySkylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);
    
    // 绘制城市建筑剪影
    final buildings = [
      [0.0, 0.3],
      [0.1, 0.5],
      [0.2, 0.2],
      [0.3, 0.4],
      [0.4, 0.3],
      [0.5, 0.6],
      [0.6, 0.3],
      [0.7, 0.5],
      [0.8, 0.2],
      [0.9, 0.4],
      [1.0, 0.3],
    ];
    
    for (int i = 0; i < buildings.length; i++) {
      final x = buildings[i][0] * size.width;
      final height = buildings[i][1] * size.height;
      if (i == 0) {
        path.lineTo(x, size.height - height);
      } else {
        path.lineTo(x, size.height - height);
      }
    }
    
    path.lineTo(size.width, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 丝带横幅绘制器
class _RibbonPainter extends CustomPainter {
  final String text;

  _RibbonPainter({required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制丝带背景
    final ribbonPaint = Paint()
      ..color = const Color(0xFF8B4513) // 棕色
      ..style = PaintingStyle.fill;

    final ribbonPath = Path();
    // 绘制丝带形状（带波浪边缘）
    ribbonPath.moveTo(0, size.height * 0.5);
    ribbonPath.quadraticBezierTo(size.width * 0.1, size.height * 0.3, size.width * 0.2, size.height * 0.5);
    ribbonPath.lineTo(size.width * 0.8, size.height * 0.5);
    ribbonPath.quadraticBezierTo(size.width * 0.9, size.height * 0.7, size.width, size.height * 0.5);
    ribbonPath.lineTo(size.width, size.height);
    ribbonPath.lineTo(0, size.height);
    ribbonPath.close();
    
    canvas.drawPath(ribbonPath, ribbonPaint);
    
    // 绘制文字
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      textAlign: TextAlign.center,
    );
    textPainter.layout(maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
