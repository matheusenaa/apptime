import 'package:flutter/material.dart';

/// Esqueleto de carregamento (linha cinza animada).
class LoadingSkeleton extends StatefulWidget {
  final int lines;
  const LoadingSkeleton({super.key, this.lines = 4});

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bright = Theme.of(context).brightness;
    final base = bright == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE6E6E6);
    final highlight = bright == Brightness.dark
        ? const Color(0xFF383838)
        : const Color(0xFFF2F2F2);

    return Column(
      children: List.generate(widget.lines, (i) {
        return FadeTransition(
          opacity: Tween(begin: 0.4, end: 1.0).animate(CurvedAnimation(
            parent: _controller,
            curve: Interval(
              (i % 3) * 0.15,
              1.0,
              curve: Curves.easeInOut,
            ),
          )),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [base, highlight, base],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }),
    );
  }
}
