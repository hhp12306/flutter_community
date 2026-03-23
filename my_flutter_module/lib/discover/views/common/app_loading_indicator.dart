import 'package:flutter/material.dart';

/// 通用加载组件：支持自定义图片、尺寸和旋转动画
class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({
    super.key,
    this.imagePath = 'assets/images/nature-landscape-with-hand-holding-frame.jpg',
    this.size = 220,
    this.fit = BoxFit.contain,
    this.center = true,
    this.animate = true,
    this.duration = const Duration(milliseconds: 900),
  });

  final String imagePath;
  final double size;
  final BoxFit fit;
  final bool center;
  final bool animate;
  final Duration duration;

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AppLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      widget.imagePath,
      width: widget.size,
      height: widget.size,
      fit: widget.fit,
    );

    final animated = widget.animate
        ? RotationTransition(
            turns: _controller,
            child: image,
          )
        : image;

    if (widget.center) {
      return Center(child: animated);
    }
    return animated;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
