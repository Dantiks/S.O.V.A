import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sova/core/constants/app_colors.dart';
import 'package:sova/core/constants/app_text_styles.dart';
import 'package:sova/presentation/widgets/glassmorphic_container.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.darkBackground,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'S.O.V.A',
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.white,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {},
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Total Balance Card
                _buildTotalBalanceCard()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 20),

                // Quick Actions
                _buildQuickActions()
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // AI Insights
                Text(
                  'Рекомендации AI',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAIInsights()
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Recent Transactions
                Text(
                  'Последние операции',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecentTransactions()
                    .animate()
                    .fadeIn(delay: 600.ms, duration: 400.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    return GlassmorphicContainer(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Общий баланс',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.gray300,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '+12.5%',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ShaderMask(
              shaderCallback: (bounds) => AppColors.purpleGradient.createShader(bounds),
              child: Text(
                '125,450 ₸',
                style: AppTextStyles.currency.copyWith(
                  color: AppColors.white,
                  fontSize: 40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildBalanceInfo(
                    'Доход',
                    '85,000 ₸',
                    AppColors.success,
                    Icons.arrow_downward,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.darkBorder,
                ),
                Expanded(
                  child: _buildBalanceInfo(
                    'Расход',
                    '42,550 ₸',
                    AppColors.error,
                    Icons.arrow_upward,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceInfo(String label, String amount, Color color, IconData icon) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.add_circle_outline, 'label': 'Добавить\nсчет', 'color': AppColors.purple},
      {'icon': Icons.swap_horiz, 'label': 'Перевод', 'color': AppColors.info},
      {'icon': Icons.analytics, 'label': 'Отчеты', 'color': AppColors.success},
      {'icon': Icons.settings, 'label': 'Настройки', 'color': AppColors.warning},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions.map((action) {
        return GestureDetector(
          onTap: () {},
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (action['color'] as Color).withOpacity(0.3),
                  ),
                ),
                child: Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                action['label'] as String,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.gray300,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAIInsights() {
    return GlassmorphicContainer(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.purpleGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.lightbulb_outline,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Совет дня',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ваши расходы на рестораны выросли на 35% в этом месяце. Рекомендуем сократить их на 15,000 ₸ для достижения цели по накоплениям.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray300,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactions = [
      {
        'title': 'Супермаркет "Народный"',
        'category': 'Продукты',
        'amount': '-2,450 ₸',
        'date': 'Сегодня, 14:30',
        'icon': Icons.shopping_cart,
        'color': AppColors.error,
      },
      {
        'title': 'Зарплата',
        'category': 'Доход',
        'amount': '+85,000 ₸',
        'date': 'Вчера, 09:00',
        'icon': Icons.attach_money,
        'color': AppColors.success,
      },
      {
        'title': 'Кафе "Coffeeshop"',
        'category': 'Рестораны',
        'amount': '-850 ₸',
        'date': 'Вчера, 16:45',
        'icon': Icons.local_cafe,
        'color': AppColors.error,
      },
    ];

    return Column(
      children: transactions.map((transaction) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GlassmorphicContainer(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (transaction['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction['icon'] as IconData,
                  color: transaction['color'] as Color,
                ),
              ),
              title: Text(
                transaction['title'] as String,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.white,
                ),
              ),
              subtitle: Text(
                transaction['date'] as String,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray400,
                ),
              ),
              trailing: Text(
                transaction['amount'] as String,
                style: AppTextStyles.titleMedium.copyWith(
                  color: transaction['color'] as Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
