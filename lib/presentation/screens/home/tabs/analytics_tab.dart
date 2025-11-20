import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sova/core/constants/app_colors.dart';
import 'package:sova/core/constants/app_text_styles.dart';
import 'package:sova/presentation/widgets/glassmorphic_container.dart';

class AnalyticsTab extends ConsumerStatefulWidget {
  const AnalyticsTab({super.key});

  @override
  ConsumerState<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<AnalyticsTab> {
  String _selectedPeriod = 'Месяц';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитика'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            icon: const Icon(Icons.calendar_today),
            color: AppColors.darkCard,
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
            },
            itemBuilder: (context) => ['Неделя', 'Месяц', 'Год']
                .map((period) => PopupMenuItem(
                      value: period,
                      child: Text(
                        period,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Spending Chart
          _buildSpendingChart(),
          const SizedBox(height: 24),

          // Category Breakdown
          Text(
            'Расходы по категориям',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildCategoryBreakdown(),

          const SizedBox(height: 24),

          // Income vs Expenses
          Text(
            'Доходы и расходы',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildIncomeExpensesChart(),
        ],
      ),
    );
  }

  Widget _buildSpendingChart() {
    return GlassmorphicContainer(
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Динамика расходов',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10000,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppColors.darkBorder,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.gray400,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${(value / 1000).toInt()}k',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.gray400,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 15000),
                        const FlSpot(1, 22000),
                        const FlSpot(2, 18000),
                        const FlSpot(3, 25000),
                        const FlSpot(4, 20000),
                        const FlSpot(5, 30000),
                        const FlSpot(6, 28000),
                      ],
                      isCurved: true,
                      gradient: AppColors.purpleGradient,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.purple.withOpacity(0.3),
                            AppColors.purple.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    final categories = [
      {'name': 'Продукты', 'amount': 15200, 'percentage': 35, 'color': AppColors.error},
      {'name': 'Транспорт', 'amount': 8500, 'percentage': 20, 'color': AppColors.info},
      {'name': 'Развлечения', 'amount': 6800, 'percentage': 16, 'color': AppColors.warning},
      {'name': 'Рестораны', 'amount': 5900, 'percentage': 14, 'color': AppColors.success},
      {'name': 'Другое', 'amount': 6150, 'percentage': 15, 'color': AppColors.gray500},
    ];

    return GlassmorphicContainer(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: category['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            category['name'] as String,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${category['amount']} ₸',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            '${category['percentage']}%',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.gray400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (category['percentage'] as int) / 100,
                      backgroundColor: AppColors.darkBorder,
                      valueColor: AlwaysStoppedAnimation(
                        category['color'] as Color,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIncomeExpensesChart() {
    return GlassmorphicContainer(
      child: Container(
        padding: const EdgeInsets.all(20),
        height: 250,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100000,
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    const months = ['Янв', 'Фев', 'Мар', 'Апр'];
                    if (value.toInt() >= 0 && value.toInt() < months.length) {
                      return Text(
                        months[value.toInt()],
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.gray400,
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${(value / 1000).toInt()}k',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.gray400,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barGroups: [
              _buildBarGroup(0, 85000, 42000),
              _buildBarGroup(1, 78000, 45000),
              _buildBarGroup(2, 92000, 38000),
              _buildBarGroup(3, 85000, 42550),
            ],
          ),
        ),
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double income, double expense) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: income,
          color: AppColors.success,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
        BarChartRodData(
          toY: expense,
          color: AppColors.error,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
