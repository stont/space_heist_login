// lib/login_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:audioplayers/audioplayers.dart';
import 'background_painter.dart';
import 'space_vault.dart';
import 'agent_avatar.dart';
import 'animated_text_field.dart';
import 'breach_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final focusNode = FocusNode();

  bool isBreaching = false;
  bool breachSuccess = false;
  bool breachFailure = false;

  late final AnimationController _vaultAnimationController;
  late final AnimationController _scanAnimationController;
  late final AnimationController _breachAnimationController;
  late final AudioPlayer _audioPlayer;

  String agentName = "Unknown Agent";

  @override
  void initState() {
    super.initState();

    _vaultAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: false);

    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _breachAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    _audioPlayer = AudioPlayer();

    emailController.addListener(_updateAgentName);
    passwordController.addListener(_onPasswordChange);
  }

  void _updateAgentName() {
    if (emailController.text.contains('@')) {
      setState(() {
        agentName = emailController.text.split('@')[0].toUpperCase();
      });
    }
  }

  void _onPasswordChange() {
    if (passwordController.text.isNotEmpty) {
      _playLockSound();
    }
  }

  Future<void> _playLockSound() async {
    try {
      // This would play a lock clicking sound in a real app
      // await _audioPlayer.play(AssetSource('audio/lock_click.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> _playBreachSound() async {
    try {
      // This would play a more dramatic sound when breaching
      // await _audioPlayer.play(AssetSource('audio/breach.mp3'));
    } catch (e) {
      debugPrint('Error playing breach sound: $e');
    }
  }

  void _attemptBreach() async {
    FocusScope.of(context).unfocus();
    _playBreachSound();

    setState(() {
      isBreaching = true;
    });

    // Simulate authentication with animation
    await _breachAnimationController.forward();

    // Mock authentication logic
    if (emailController.text.isNotEmpty && passwordController.text.length >= 6) {
      setState(() {
        breachSuccess = true;
        breachFailure = false;
      });

      // Simulate transition to main app after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      _showSuccessDialog();
    } else {
      setState(() {
        breachSuccess = false;
        breachFailure = true;
      });

      // Reset after failure animation
      await Future.delayed(const Duration(seconds: 2));
      _breachAnimationController.reset();
      setState(() {
        isBreaching = false;
        breachFailure = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1020),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: const Color(0xFF00FF80), width: 2),
        ),
        title: Text(
          'ACCESS GRANTED',
          style: TextStyle(color: const Color(0xFF00FF80)),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: const Color(0xFF00FF80), size: 60)
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              'Welcome back, AGENT $agentName',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('CONTINUE TO SECURE AREA'),
            onPressed: () {
              Navigator.of(context).pop();
              _resetLoginState();
            },
          ),
        ],
      ),
    );
  }

  void _resetLoginState() {
    _breachAnimationController.reset();
    setState(() {
      isBreaching = false;
      breachSuccess = false;
      breachFailure = false;
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    focusNode.dispose();
    _vaultAnimationController.dispose();
    _scanAnimationController.dispose();
    _breachAnimationController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (full screen)
          Positioned.fill(
            child: CustomPaint(
              painter: BackgroundPainter(
                animation: _vaultAnimationController,
              ),
            ),
          ),

          // Main content (centered)
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Title
                  Text(
                    'SPACE HEIST',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                      shadows: [
                        Shadow(
                          color: Colors.blueAccent.withOpacity(0.7),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    'SECURITY LOGIN',
                    style: TextStyle(
                      color: const Color(0xFF8080FF),
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Space Vault (centered)
                  Center(
                    child: SpaceVault(
                      animation: _vaultAnimationController,
                      breachAnimation: _breachAnimationController,
                      size: MediaQuery.of(context).size.width * 0.7,
                      isBreaching: isBreaching,
                      isSuccess: breachSuccess,
                      isFailure: breachFailure,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Login Form (centered and constrained width)
                  Container(
                    constraints: BoxConstraints(maxWidth: 400),
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Agent Avatar
                        if (emailController.text.isNotEmpty)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: AgentAvatar(
                                email: emailController.text,
                                animation: _breachAnimationController,
                                isBreaching: isBreaching,
                                isSuccess: breachSuccess,
                                isFailure: breachFailure,
                              ),
                            ),
                          ),

                        // Email Field
                        AnimatedTextField(
                          controller: emailController,
                          scanAnimation: _scanAnimationController,
                          labelText: 'Retinal ID (Email)',
                          hintText: 'Enter your identification',
                          icon: Icons.visibility,
                          scanColor: const Color(0xFF00FF80),
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isBreaching,
                        ),

                        const SizedBox(height: 20),

                        // Password Field
                        AnimatedTextField(
                          controller: passwordController,
                          scanAnimation: _scanAnimationController,
                          labelText: 'Security Key (Password)',
                          hintText: 'Enter your security key',
                          icon: Icons.lock_outline,
                          scanColor: const Color(0xFFFFCC00),
                          obscureText: true,
                          enabled: !isBreaching,
                          showTumblers: true,
                        ),

                        const SizedBox(height: 40),

                        // Breach Button
                        BreachButton(
                          onPressed: !isBreaching ? _attemptBreach : null,
                          animation: _breachAnimationController,
                          isBreaching: isBreaching,
                        ),

                        const SizedBox(height: 30),

                        // Status Message
                        AnimatedOpacity(
                          opacity: breachFailure ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            'INTRUDER DETECTED: ACCESS DENIED',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Forgot Password Link
                        TextButton(
                          onPressed: !isBreaching ? () {} : null,
                          child: Text(
                            'Forgot Security Clearance?',
                            style: TextStyle(color: const Color(0xFF8080FF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}