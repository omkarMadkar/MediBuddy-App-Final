import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await _logoController.forward();
    await _textController.forward();
    _pulseController.repeat(reverse: true);

    // Wait for 3 seconds then navigate
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFE3F2FD), Color(0xFFB3E5FC)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // Logo Section
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF20B2AA),
                                    Color(0xFF00CED1),
                                    Color(0xFF1E90FF),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF20B2AA,
                                    ).withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                FontAwesomeIcons.heartPulse,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // App Name and Tagline
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        const Text(
                          'MediBuddy',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C3E50),
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your Personal Health Companion',
                          style: TextStyle(
                            fontSize: 18,
                            color: const Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Monitor • Predict • Improve',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF20B2AA),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const Spacer(),

              // Loading Section
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF20B2AA),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Initializing your health journey...',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color(0xFF7F8C8D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
