import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/constants/app_colors.dart';
import 'package:finer/presentation/screens/home/tabs/dashboard_tab.dart';
import 'package:finer/presentation/screens/home/tabs/accounts_tab.dart';
import 'package:finer/presentation/screens/home/tabs/chat_tab.dart';
import 'package:finer/presentation/screens/home/tabs/analytics_tab.dart';
import 'package:finer/presentation/screens/home/tabs/profile_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardTab(),
    AccountsTab(),
    ChatTab(),
    AnalyticsTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Главная',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Счета',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.chat_bubble_rounded,
                  label: 'AI',
                  index: 2,
                  isCenter: true,
                ),
                _buildNavItem(
                  icon: Icons.analytics_rounded,
                  label: 'Аналитика',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Профиль',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool isCenter = false,
  }) {
    final isSelected = _selectedIndex == index;

    if (isCenter) {
      return GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isSelected
                ? AppColors.purpleGradient
                : const LinearGradient(
                    colors: [AppColors.darkCard, AppColors.darkCard],
                  ),
            boxShadow: isSelected ? AppColors.purpleShadow : null,
          ),
          child: Icon(
            icon,
            color: AppColors.white,
            size: 28,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.purple.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.purple : AppColors.gray500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.purple : AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
