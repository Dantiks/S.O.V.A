import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sova/core/constants/app_colors.dart';
import 'package:sova/core/constants/app_text_styles.dart';
import 'package:sova/presentation/providers/auth_provider.dart';
import 'package:sova/presentation/widgets/glassmorphic_container.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.black,
              AppColors.darkSurface,
              AppColors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.purpleGradient,
                      boxShadow: AppColors.glowShadow,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 60,
                      color: AppColors.white,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(delay: 200.ms, duration: 400.ms),
                  
                  const SizedBox(height: 40),
                  
                  // Title
                  Text(
                    'S.O.V.A',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.white,
                      letterSpacing: 4,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  Text(
                    'Ваш персональный финансовый ассистент',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.gray400,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms),
                  
                  const SizedBox(height: 60),
                  
                  // Sign In Button
                  GlassmorphicContainer(
                    child: authState.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.purple,
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithGoogle();
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 20,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Image.asset(
                                    'assets/images/google_logo.png',
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.login,
                                        color: AppColors.white,
                                        size: 24,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    'Войти через Google',
                                    style: AppTextStyles.button.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 40),
                  
                  // Features
                  _buildFeaturesList()
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 600.ms),
                  
                  // Error Message
                  if (authState.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Text(
                        authState.error.toString(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      'AI-анализ ваших финансов',
      'Управление всеми счетами',
      'Персональные рекомендации',
      'Банковская защита данных',
    ];

    return Column(
      children: features.map((feature) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.purple,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                feature,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray300,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
