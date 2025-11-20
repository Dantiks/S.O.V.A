import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Добро пожаловать в S.O.V.A',
      description: 'Ваш персональный финансовый ассистент с искусственным интеллектом',
      icon: Icons.rocket_launch,
      color: const Color(0xFF7A3DF2),
    ),
    OnboardingPage(
      title: 'AI-Ассистент',
      description: 'Умный помощник анализирует ваши финансы и дает персональные рекомендации',
      icon: Icons.psychology,
      color: const Color(0xFF3B82F6),
    ),
    OnboardingPage(
      title: 'Все банки в одном месте',
      description: 'Управляйте счетами всех банков Кыргызстана из одного приложения',
      icon: Icons.account_balance,
      color: const Color(0xFF10B981),
    ),
    OnboardingPage(
      title: 'Банковская безопасность',
      description: 'Face ID, PIN-код и шифрование защищают ваши данные',
      icon: Icons.security,
      color: const Color(0xFFF59E0B),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: Color(0xFF7A3DF2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () => _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                          child: const Text('Назад'),
                        ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _currentPage == _pages.length - 1
                            ? () {
                                if (mounted) {
                                  Navigator.pushReplacementNamed(context, '/auth');
                                }
                              }
                            : () => _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                ),
                        child: Text(_currentPage == _pages.length - 1 ? 'Начать' : 'Далее'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 60, color: page.color),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
