// lib/background_painter.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class BackgroundPainter extends CustomPainter {
  final Animation<double> animation;

  BackgroundPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Create a radial gradient for the space nebula background
    final Paint backgroundPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: const [
          Color(0xFF1A0033),
          Color(0xFF000066),
          Color(0xFF000033),
          Color(0xFF000011),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(rect);
    // Draw background
    canvas.drawRect(rect, backgroundPaint);

    // Draw stars
    final random = math.Random(42);
    final starPaint = Paint()..color = Colors.white;

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;

      // Make some stars twinkle based on the animation
      final twinkle = math.sin((animation.value * math.pi * 2) + i) * 0.5 + 0.5;

      if (i % 3 == 0) {
        starPaint.color = Colors.white.withOpacity(0.3 + (twinkle * 0.7));
      } else {
        starPaint.color = Colors.white.withOpacity(0.7);
      }

      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    // Draw distant nebula clouds
    final nebulaPaint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.screen;

    for (int i = 0; i < 3; i++) {
      final nebulaX = size.width * (0.2 + (i * 0.3));
      final nebulaY = size.height * (0.1 + (i * 0.3));
      final nebulaRadius = size.width * 0.15;

      // Animate nebula color slightly
      final hueShift = math.sin(animation.value * math.pi * 2 + i);

      if (i == 0) {
        nebulaPaint.color = Color.fromARGB(
          40,
          100 + (hueShift * 20).toInt(),
          20,
          150,
        );
      } else if (i == 1) {
        nebulaPaint.color = Color.fromARGB(
          30,
          20,
          100 + (hueShift * 20).toInt(),
          150,
        );
      } else {
        nebulaPaint.color = Color.fromARGB(
          25,
          20,
          50,
          150 + (hueShift * 20).toInt(),
        );
      }

      // Draw nebula cloud
      canvas.drawCircle(Offset(nebulaX, nebulaY), nebulaRadius, nebulaPaint);
    }
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => true;
}