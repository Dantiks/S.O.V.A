import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:finer/core/theme/glass_theme.dart';

class OnboardingImprovedScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingImprovedScreen({super.key, required this.onComplete});

  @override
  State<OnboardingImprovedScreen> createState() => _OnboardingImprovedScreenState();
}

class _OnboardingImprovedScreenState extends State<OnboardingImprovedScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Добро пожаловать в S.O.V.A',
      description: 'Smart Omniscient Virtual Assistant - ваш умный финансовый помощник',
      icon: '🦉',
      gradient: const LinearGradient(
        colors: [Color(0xFF7A3DF2), Color(0xFF5B2DBF)],
      ),
    ),
    OnboardingPage(
      title: 'Управляйте финансами',
      description: 'Отслеживайте доходы и расходы, анализируйте траты по категориям',
      icon: '💰',
      gradient: const LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
      ),
    ),
    OnboardingPage(
      title: 'Достигайте целей',
      description: 'Создавайте цели накоплений и следите за прогрессом их достижения',
      icon: '🎯',
      gradient: const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
      ),
    ),
    OnboardingPage(
      title: 'AI-помощник',
      description: 'Получайте персональные советы и прогнозы от умного ассистента',
      icon: '🤖',
      gradient: const LinearGradient(
        colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
      ),
    ),
    OnboardingPage(
      title: 'Безопасность',
      description: 'Ваши данные защищены PIN-кодом и биометрией',
      icon: '🔒',
      gradient: const LinearGradient(
        colors: [Color(0xFFE91E63), Color(0xFFC2185B)],
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF0f0f1e),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              if (_currentPage < _pages.length - 1)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextButton(
                      onPressed: widget.onComplete,
                      child: Text(
                        'Пропустить',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 68),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Page Indicator
              Padding(
                padding: const EdgeInsets.all(20),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: _pages.length,
                  effect: WormEffect(
                    dotColor: Colors.white.withOpacity(0.3),
                    activeDotColor: const Color(0xFF7A3DF2),
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 12,
                  ),
                ),
              ),

              // Next/Get Started Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: WaterRippleButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      widget.onComplete();
                    }
                  },
                  height: 56,
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Далее' : 'Начать',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: page.gradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: page.gradient.colors.first.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Text(
                page.icon,
                style: const TextStyle(fontSize: 80),
              ),
            ),
          ),
          const SizedBox(height: 60),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String icon;
  final Gradient gradient;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}
