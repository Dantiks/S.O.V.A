import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finer/core/constants/app_colors.dart';
import 'package:finer/core/constants/app_text_styles.dart';
import 'package:finer/presentation/screens/splash/widgets/geometric_owl_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _owlAnimation;
  late Animation<double> _textAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _owlAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate after animation
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        // TODO: Navigate to appropriate screen based on auth state
        // context.go('/onboarding') or context.go('/home')
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Geometric Owl
            AnimatedBuilder(
              animation: _owlAnimation,
              builder: (context, child) {
                return SizedBox(
                  width: 200,
                  height: 200,
                  child: CustomPaint(
                    painter: GeometricOwlPainter(
                      progress: _owlAnimation.value,
                      color: AppColors.white,
                      glowColor: AppColors.purple,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            // Animated Text
            AnimatedBuilder(
              animation: _textAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textAnimation.value,
                  child: Transform.scale(
                    scale: 0.8 + (_textAnimation.value * 0.2),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AppColors.white,
                          AppColors.purple.withOpacity(0.8),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'S.O.V.A',
                        style: AppTextStyles.displayLarge.copyWith(
                          color: AppColors.white,
                          letterSpacing: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
