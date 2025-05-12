// lib/space_vault.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SpaceVault extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> breachAnimation;
  final double size;
  final bool isBreaching;
  final bool isSuccess;
  final bool isFailure;

  const SpaceVault({
    Key? key,
    required this.animation,
    required this.breachAnimation,
    required this.size,
    this.isBreaching = false,
    this.isSuccess = false,
    this.isFailure = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([animation, breachAnimation]),
      builder: (context, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: _VaultPainter(
            animation: animation.value,
            breachAnimation: breachAnimation.value,
            isBreaching: isBreaching,
            isSuccess: isSuccess,
            isFailure: isFailure,
          ),
        );
      },
    );
  }
}

class _VaultPainter extends CustomPainter {
  final double animation;
  final double breachAnimation;
  final bool isBreaching;
  final bool isSuccess;
  final bool isFailure;

  _VaultPainter({
    required this.animation,
    required this.breachAnimation,
    required this.isBreaching,
    required this.isSuccess,
    required this.isFailure,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw vault outline
    final vaultPaint = Paint()
      ..color = const Color(0xFF162138)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, vaultPaint);

    // Draw vault border
    final borderPaint = Paint()
      ..color = const Color(0xFF506A95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, borderPaint);

    // Inner circles
    final innerCirclePaint = Paint()
      ..color = const Color(0xFF3A4F73)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(center, radius * 0.85, innerCirclePaint);

    innerCirclePaint.strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.7, innerCirclePaint);

    // Vault door lines
    final doorLinePaint = Paint()
      ..color = const Color(0xFF506A95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      doorLinePaint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      doorLinePaint,
    );

    // Security lights
    final lightColor = isFailure
        ? const Color(0xFFFF0000)
        : isSuccess
        ? const Color(0xFF00FF00)
        : isBreaching
        ? Color.lerp(
      const Color(0xFFFF3333),
      const Color(0xFFFFFF00),
      math.sin(breachAnimation * math.pi * 5),
    )! // Blinking during breach
        : const Color(0xFFFF3333);

    final lightPaint = Paint()..color = lightColor;

    // Draw security lights with glow effect
    _drawGlowingCircle(
      canvas,
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.5),
      radius * 0.07,
      lightPaint,
      lightColor,
    );

    _drawGlowingCircle(
      canvas,
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5),
      radius * 0.07,
      lightPaint,
      lightColor,
    );

    _drawGlowingCircle(
      canvas,
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5),
      radius * 0.07,
      lightPaint,
      lightColor,
    );

    _drawGlowingCircle(
      canvas,
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.5),
      radius * 0.07,
      lightPaint,
      lightColor,
    );

    // Center lock
    final centerLockPaint = Paint()..color = const Color(0xFF0A1020);
    canvas.drawCircle(center, radius * 0.25, centerLockPaint);

    final centerLockBorderPaint = Paint()
      ..color = const Color(0xFF506A95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius * 0.25, centerLockBorderPaint);

    final innerLockPaint = Paint()..color = const Color(0xFF142038);
    canvas.drawCircle(center, radius * 0.2, innerLockPaint);

    final innerLockBorderPaint = Paint()
      ..color = const Color(0xFF3A4F73)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius * 0.2, innerLockBorderPaint);

    // Draw "SECURE" text
    final textSpan = TextSpan(
      text: isSuccess ? 'OPEN' : 'SECURE',
      style: TextStyle(
        color: isSuccess ? const Color(0xFF00FF80) : const Color(0xFF80C0FF),
        fontSize: radius * 0.1,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    textPainter.layout();

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);

    // Draw breach effect
    if (isBreaching) {
      // Rotation effect
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(breachAnimation * math.pi * 2);
      canvas.translate(-center.dx, -center.dy);

      final breachPaint = Paint()
        ..color = const Color(0xFFFFCC00).withOpacity(breachAnimation * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * math.pi;
        final pulseFactor = math.sin(breachAnimation * math.pi * 10 + i);
        final start = radius * (0.4 + (pulseFactor * 0.05));
        final end = radius * (0.9 + (pulseFactor * 0.05));

        canvas.drawLine(
          Offset(
            center.dx + math.cos(angle) * start,
            center.dy + math.sin(angle) * start,
          ),
          Offset(
            center.dx + math.cos(angle) * end,
            center.dy + math.sin(angle) * end,
          ),
          breachPaint,
        );
      }

      canvas.restore();
    }

    // Success effect
    if (isSuccess) {
      final successPaint = Paint()
        ..color = const Color(0xFF00FF80).withOpacity(0.3)
        ..style = PaintingStyle.fill;

      // Inner glow
      canvas.drawCircle(center, radius * 0.7, successPaint);

      // Radiating waves
      for (int i = 0; i < 3; i++) {
        final waveRadius = radius * (0.8 + (i * 0.2)) * breachAnimation;
        final wavePaint = Paint()
          ..color = const Color(0xFF00FF80).withOpacity(0.2 * (1 - (i * 0.3)))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

        canvas.drawCircle(center, waveRadius, wavePaint);
      }
    }

    // Failure effect
    if (isFailure) {
      final failurePaint = Paint()
        ..color = const Color(0xFFFF0000).withOpacity(0.3)
        ..style = PaintingStyle.fill;

      // Inner glow
      canvas.drawCircle(center, radius * 0.7, failurePaint);

      // Danger pattern
      final dangerPaint = Paint()
        ..color = const Color(0xFFFF0000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      for (int i = 0; i < 6; i++) {
        final angle = (i / 6) * 2 * math.pi;
        final flashFactor = math.sin(breachAnimation * math.pi * 20);

        if (flashFactor > 0) {
          canvas.drawLine(
            center,
            Offset(
              center.dx + math.cos(angle) * radius * 0.8,
              center.dy + math.sin(angle) * radius * 0.8,
            ),
            dangerPaint,
          );
        }
      }
    }
  }

  void _drawGlowingCircle(
      Canvas canvas,
      Offset center,
      double radius,
      Paint paint,
      Color color,
      ) {
    // Draw glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawCircle(center, radius * 1.3, glowPaint);

    // Draw solid circle
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(_VaultPainter oldDelegate) =>
      animation != oldDelegate.animation ||
          breachAnimation != oldDelegate.breachAnimation ||
          isBreaching != oldDelegate.isBreaching ||
          isSuccess != oldDelegate.isSuccess ||
          isFailure != oldDelegate.isFailure;
}
