import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_provider.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Logo scale + fade
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  // Ring pulse
  late AnimationController _ringController;
  late Animation<double> _ring1Scale;
  late Animation<double> _ring1Opacity;
  late Animation<double> _ring2Scale;
  late Animation<double> _ring2Opacity;

  // Text slide up
  late AnimationController _textController;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleFade;

  // Tagline + bar
  late AnimationController _taglineController;
  late Animation<double> _taglineFade;
  late Animation<double> _barWidth;

  // Exit fade
  late AnimationController _exitController;
  late Animation<double> _exitFade;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Ring pulse (starts after logo)
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ring1Scale = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
    _ring1Opacity = Tween<double>(begin: 0.35, end: 0.0).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeOut),
    );
    _ring2Scale = Tween<double>(begin: 1.0, end: 2.8).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
      ),
    );
    _ring2Opacity = Tween<double>(begin: 0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _ringController,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
      ),
    );

    // Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textController, curve: Curves.easeOut));
    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _textController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
          ),
        );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    // Tagline + bar
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _barWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _taglineController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Exit fade
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _ringController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _taglineController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    await _exitController.forward();

    if (!mounted) return;
    final provider = context.read<AppProvider>();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
        provider.currentUser != null ? const HomeScreen() : const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _ringController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: FadeTransition(
        opacity: _exitFade,
        child: Stack(
          children: [
            // Background gradient mesh
            Positioned.fill(
              child: CustomPaint(painter: _BackgroundPainter()),
            ),

            // Bottom decorative arc
            Positioned(
              bottom: -size.width * 0.3,
              left: -size.width * 0.2,
              right: -size.width * 0.2,
              child: Container(
                height: size.width * 0.9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryBlue.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content centered
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with pulse rings
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ring 2 (outer)
                        AnimatedBuilder(
                          animation: _ringController,
                          builder: (_, __) => Transform.scale(
                            scale: _ring2Scale.value,
                            child: Opacity(
                              opacity: _ring2Opacity.value,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.accentBlue,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Ring 1 (inner)
                        AnimatedBuilder(
                          animation: _ringController,
                          builder: (_, __) => Transform.scale(
                            scale: _ring1Scale.value,
                            child: Opacity(
                              opacity: _ring1Opacity.value,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.primaryBlue,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Logo icon
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (_, __) => FadeTransition(
                            opacity: _logoFade,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2D4090),
                                      AppTheme.accentBlue,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryBlue.withOpacity(0.5),
                                      blurRadius: 28,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 38,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App name
                  SlideTransition(
                    position: _titleSlide,
                    child: FadeTransition(
                      opacity: _titleFade,
                      child: const Text(
                        'Expense Tracker',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle
                  SlideTransition(
                    position: _subtitleSlide,
                    child: FadeTransition(
                      opacity: _subtitleFade,
                      child: const Text(
                        'Track your expenses in PKR',
                        style: TextStyle(
                          color: AppTheme.darkTextSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Animated progress bar
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _barWidth,
                          builder: (_, __) => Container(
                            width: 160,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppTheme.darkCardAlt,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _barWidth.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryBlue.withOpacity(0.6),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Smart • Simple • Secure',
                          style: TextStyle(
                            color: Color(0xFF4C6EF5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Version tag bottom
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _taglineFade,
                child: const Center(
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: AppTheme.darkTextSecondary,
                      fontSize: 11,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Top-right glow blob
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF3B5BDB).withOpacity(0.18),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.85, size.height * 0.12),
      radius: size.width * 0.55,
    ));
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.12),
      size.width * 0.55,
      paint,
    );

    // Bottom-left glow blob
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF4C6EF5).withOpacity(0.12),
        Colors.transparent,
      ],
    ).createShader(Rect.fromCircle(
      center: Offset(size.width * 0.1, size.height * 0.88),
      radius: size.width * 0.5,
    ));
    canvas.drawCircle(
      Offset(size.width * 0.1, size.height * 0.88),
      size.width * 0.5,
      paint,
    );
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) => false;
}