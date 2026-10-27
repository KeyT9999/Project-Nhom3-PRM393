import 'package:flutter/material.dart';

/// Nảy nhẹ một lần khi [count] tăng (ví dụ badge giỏ hàng khi thêm sản phẩm).
class CountBump extends StatefulWidget {
  final int count;
  final Widget child;

  const CountBump({super.key, required this.count, required this.child});

  @override
  State<CountBump> createState() => _CountBumpState();
}

class _CountBumpState extends State<CountBump>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
    TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void didUpdateWidget(CountBump old) {
    super.didUpdateWidget(old);
    if (widget.count > old.count) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}
