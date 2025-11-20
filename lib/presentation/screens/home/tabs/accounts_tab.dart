import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sova/core/constants/app_colors.dart';
import 'package:sova/core/constants/app_text_styles.dart';
import 'package:sova/core/constants/app_constants.dart';
import 'package:sova/presentation/widgets/glassmorphic_container.dart';

class AccountsTab extends ConsumerWidget {
  const AccountsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои счета'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              _showAddAccountDialog(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Total Balance
          _buildTotalBalance()
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 24),

          // Accounts List
          Text(
            'Банковские счета',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Demo accounts
          _buildAccountCard(
            bankName: 'Optima Bank',
            accountNumber: '**** 1234',
            balance: 45250.00,
            currency: 'KGS',
            color: AppColors.purple,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),

          const SizedBox(height: 12),

          _buildAccountCard(
            bankName: 'KICB',
            accountNumber: '**** 5678',
            balance: 80200.00,
            currency: 'KGS',
            color: AppColors.info,
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms),

          const SizedBox(height: 24),

          // Add Account Button
          _buildAddAccountButton(context)
              .animate()
              .fadeIn(delay: 600.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildTotalBalance() {
    return GlassmorphicContainer(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Общий баланс',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.gray300,
              ),
            ),
            const SizedBox(height: 12),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.purpleGradient.createShader(bounds),
              child: Text(
                '125,450 ₸',
                style: AppTextStyles.currency.copyWith(
                  color: AppColors.white,
                  fontSize: 36,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '2 счета',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard({
    required String bankName,
    required String accountNumber,
    required double balance,
    required String currency,
    required Color color,
  }) {
    return GlassmorphicContainer(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: color,
                    size: 24,
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.gray400),
                  color: AppColors.darkCard,
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text(
                        'Подробнее',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      child: Text(
                        'Обновить',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    PopupMenuItem(
                      child: Text(
                        'Удалить',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              bankName,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              accountNumber,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray400,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Баланс',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
                Text(
                  '${balance.toStringAsFixed(2)} $currency',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAccountButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddAccountDialog(context),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.purple.withOpacity(0.5),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline,
              color: AppColors.purple,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Добавить банковский счет',
              style: AppTextStyles.titleSmall.copyWith(
                color: AppColors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Выберите банк',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: AppConstants.supportedBanks.length,
                  itemBuilder: (context, index) {
                    final bank = AppConstants.supportedBanks[index];
                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: AppColors.purple,
                        ),
                      ),
                      title: Text(
                        bank,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.gray400,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Navigate to bank connection screen
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
