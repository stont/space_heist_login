// lib/animated_text_field.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final Animation<double> scanAnimation;
  final String labelText;
  final String hintText;
  final IconData icon;
  final Color scanColor;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool enabled;
  final bool showTumblers;

  const AnimatedTextField({
    Key? key,
    required this.controller,
    required this.scanAnimation,
    required this.labelText,
    required this.hintText,
    required this.icon,
    required this.scanColor,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.showTumblers = false,
  }) : super(key: key);

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> with SingleTickerProviderStateMixin {
  late AnimationController _tumblerAnimationController;
  final List<double> _tumblerRotations = [];

  @override
  void initState() {
    super.initState();

    _tumblerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Initialize tumbler rotations
    for (int i = 0; i < 10; i++) {
      _tumblerRotations.add(0.0);
    }

    widget.controller.addListener(_updateTumblers);
  }

  void _updateTumblers() {
    if (widget.showTumblers && widget.controller.text.isNotEmpty) {
      final String newText = widget.controller.text;

      // Update tumbler rotations based on the latest character
      if (newText.isNotEmpty) {
        final int charCode = newText.codeUnitAt(newText.length - 1);
        final int index = newText.length - 1;

        if (index < _tumblerRotations.length) {
          setState(() {
            _tumblerRotations[index] = (charCode % 10) * (math.pi / 5);
          });

          _tumblerAnimationController.forward(from: 0.0);
        }
      }
    }
  }

  @override
  void dispose() {
    _tumblerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Text Field
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            labelStyle: TextStyle(color: widget.scanColor),
            prefixIcon: Icon(widget.icon, color: widget.scanColor),
            suffixIcon: widget.controller.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              color: widget.scanColor,
              onPressed: () {
                widget.controller.clear();
              },
            )
                : null,
          ),
        ),

        // Scanner animation
        AnimatedBuilder(
          animation: widget.scanAnimation,
          builder: (context, child) {
            return Positioned(
              left: 80,
              right: 20,
              top: 33,
              child: Opacity(
                opacity: widget.controller.text.isNotEmpty ? 0.8 : 0.2,
                child: Container(
                  height: 2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.scanColor.withOpacity(0.0),
                        widget.scanColor,
                        widget.scanColor.withOpacity(0.0),
                      ],
                      stops: [
                        0.0,
                        widget.scanAnimation.value,
                        1.0,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Password tumblers
        if (widget.showTumblers)
          Positioned(
            top: 47,
            left: 80,
            child: AnimatedBuilder(
              animation: _tumblerAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    math.min(widget.controller.text.length, 7),
                        (index) => _buildTumbler(index),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildTumbler(int index) {
    final bool isActive = index < widget.controller.text.length;
    final Animation<double> animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tumblerAnimationController,
      curve: Interval(
        index / 10,
        (index / 10) + 0.1,
        curve: Curves.elasticOut,
      ),
    ));

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _tumblerRotations[index] * animation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(
                color: isActive
                    ? widget.scanColor
                    : widget.scanColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 6,
                height: 2,
                color: isActive
                    ? widget.scanColor
                    : widget.scanColor.withOpacity(0.3),
              ),
            ),
          ),
        );
      },
    );
  }
}