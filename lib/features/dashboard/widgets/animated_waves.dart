import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedWaves extends StatefulWidget {
  final double height;
  final Color color;
  final double speed;
  final double offset;

  const AnimatedWaves({
    super.key,
    required this.height,
    required this.color,
    this.speed = 1.0,
    this.offset = 0.0,
  });

  @override
  State<AnimatedWaves> createState() => _AnimatedWavesState();
}

class _AnimatedWavesState extends State<AnimatedWaves>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: (5 / widget.speed).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: WavePainter(
            animationValue: _controller.value,
            color: widget.color,
            height: widget.height,
            offset: widget.offset,
          ),
          child: Container(),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double height;
  final double offset;

  WavePainter({
    required this.animationValue,
    required this.color,
    required this.height,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    final waveWidth = size.width;
    final waveHeight = 15.0; // Amplitude
    final yCenter = size.height - height;

    path.moveTo(0, size.height);
    path.lineTo(0, yCenter);

    for (double i = 0; i <= waveWidth; i++) {
      final x = i;
      final y = yCenter +
          math.sin((i / waveWidth * 2 * math.pi) +
                  (animationValue * 2 * math.pi) +
                  offset) *
              waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.height != height;
  }
}
