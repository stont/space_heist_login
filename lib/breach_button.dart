// lib/breach_button.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class BreachButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Animation<double> animation;
  final bool isBreaching;

  const BreachButton({
    Key? key,
    required this.onPressed,
    required this.animation,
    required this.isBreaching,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Calculate safe opacity values
        final pulseOpacity = (isBreaching
            ? math.sin(animation.value * math.pi * 5).abs() * 0.3
            : math.sin(animation.value * math.pi * 2).abs() * 0.2)
            .clamp(0.0, 1.0);

        final glowColor = isBreaching
            ? Color.lerp(
          const Color(0xFFFF0000),
          const Color(0xFFFF8800),
          (math.sin(animation.value * math.pi * 10).abs())
              .clamp(0.0, 1.0),
        )!.withOpacity(0.7.clamp(0.0, 1.0))
            : const Color(0xFFFF0000).withOpacity(0.3);

        return GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: const Color(0xFF990000),
              border: Border.all(
                color: const Color(0xFFFF6666),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: isBreaching ? 20 : 10,
                  spreadRadius: isBreaching ? 5 : 0,
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Breach Text
                  Text(
                    isBreaching ? 'BREACHING...' : 'BREACH VAULT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.red.withOpacity(0.8),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),

                  // Loading dots for breaching state
                  if (isBreaching)
                    Positioned(
                      right: 30,
                      child: _buildLoadingDots(),
                    ),

                  // Pulse overlay
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(35),
                      child: Opacity(
                        opacity: pulseOpacity,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            // Calculate safe pulsing opacity based on animation time and dot index
            final dotPhase = (animation.value * 5 + (index * 0.33)) % 1.0;
            final dotOpacity = 0.2 + (0.8 * (1 - dotPhase)).clamp(0.0, 1.0);

            return Container(
              margin: const EdgeInsets.only(left: 4),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(dotOpacity),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}