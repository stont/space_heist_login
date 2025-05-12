// lib/agent_avatar.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AgentAvatar extends StatelessWidget {
  final String email;
  final Animation<double> animation;
  final bool isBreaching;
  final bool isSuccess;
  final bool isFailure;

  const AgentAvatar({
    Key? key,
    required this.email,
    required this.animation,
    this.isBreaching = false,
    this.isSuccess = false,
    this.isFailure = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a deterministic avatar based on email
    final hash = email.hashCode.abs();
    final random = math.Random(hash);

    final baseColor = HSVColor.fromAHSV(
      1.0,
      random.nextDouble() * 360,
      0.7 + random.nextDouble() * 0.3,
      0.7 + random.nextDouble() * 0.3,
    ).toColor();

    // Create Avatar component
    Widget avatar = AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A1020),
                  border: Border.all(
                    color: isFailure
                        ? Colors.red
                        : isSuccess
                        ? Colors.green
                        : baseColor,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isBreaching ? baseColor : Colors.blueAccent)
                          .withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
              )
          );
        }
    );

    // Return the avatar widget
    return avatar;
  }

}