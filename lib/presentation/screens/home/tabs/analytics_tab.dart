import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/core/theme/glass_theme.dart';
import 'package:sova/presentation/providers/transaction_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

enum TimePeriod { week, month, year, custom }

class AnalyticsTab extends ConsumerStatefulWidget {
  const AnalyticsTab({super.key});

  @override
  ConsumerState<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<AnalyticsTab> with SingleTickerProviderStateMixin {
  TimePeriod _selectedPeriod = TimePeriod.month;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _changePeriod(TimePeriod period) {
    if (_selectedPeriod != period) {
      setState(() => _selectedPeriod = period);
      _animationController.reset();
      _animationController.forward();
    }
  }

  (DateTime, DateTime) _getDateRange() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case TimePeriod.week:
        return (now.subtract(const Duration(days: 7)), now);
      case TimePeriod.month:
        return (DateTime(now.year, now.month, 1), now);
      case TimePeriod.year:
        return (DateTime(now.year, 1, 1), now);
      case TimePeriod.custom:
        return (DateTime(now.year, now.month, 1), now);
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionProvider);
    final (startDate, endDate) = _getDateRange();
    
    final periodTransactions = ref.read(transactionProvider.notifier)
        .getByPeriod(startDate, endDate);
    
    final income = ref.read(transactionProvider.notifier)
        .getIncomeForPeriod(startDate, endDate);
    final expense = ref.read(transactionProvider.notifier)
        .getExpenseForPeriod(startDate, endDate);
    final balance = income - expense;
    
    // Категории расходов
    final Map<String, double> categoryExpenses = {};
    for (var t in periodTransactions) {
      if (t.type == TransactionType.expense) {
        categoryExpenses[t.categoryId] = (categoryExpenses[t.categoryId] ?? 0) + t.amount;
      }
    }
    final sortedCategories = categoryExpenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Аналитика',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Глубокий анализ ваших финансов',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Period Selector
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        _buildPeriodChip('Неделя', TimePeriod.week),
                        const SizedBox(width: 6),
                        _buildPeriodChip('Месяц', TimePeriod.month),
                        const SizedBox(width: 6),
                        _buildPeriodChip('Год', TimePeriod.year),
                        const SizedBox(width: 6),
                        Expanded(
                          child: WaterRippleButton(
                            onPressed: () async {
                              final DateTimeRange? picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFF7A3DF2),
                                        surface: Color(0xFF1a1a2e),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                _changePeriod(TimePeriod.custom);
                              }
                            },
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            gradient: _selectedPeriod == TimePeriod.custom ? GlassTheme.accentGradient : null,
                            child: const Icon(Icons.calendar_today, color: Colors.white, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Animated Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Balance Overview
                        _buildBalanceCard(income, expense, balance),
                        
                        const SizedBox(height: 20),
                        
                        // Chart
                        _buildChartCard(periodTransactions, startDate, endDate),
                        
                        const SizedBox(height: 20),
                        
                        // AI Insights
                        _buildAIInsights(income, expense, balance),
                        
                        const SizedBox(height: 20),
                        
                        // Category Breakdown
                        if (sortedCategories.isNotEmpty)
                          _buildCategoryBreakdown(sortedCategories, expense),
                        
                        const SizedBox(height: 20),
                        
                        // Financial Health Score
                        _buildFinancialHealthScore(income, expense),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, TimePeriod period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: WaterRippleButton(
        onPressed: () => _changePeriod(period),
        padding: const EdgeInsets.symmetric(vertical: 12),
        gradient: isSelected ? GlassTheme.accentGradient : null,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double income, double expense, double balance) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      gradient: balance >= 0 
          ? const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)])
          : const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFC62828)]),
      boxShadow: [
        BoxShadow(
          color: (balance >= 0 ? Colors.green : Colors.red).withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  balance >= 0 ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balance >= 0 ? 'Профицит' : 'Дефицит',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${balance >= 0 ? '+' : ''}${NumberFormat('#,###').format(balance)} сом',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem('Доход', income, Icons.arrow_downward, Colors.white),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildBalanceItem('Расход', expense, Icons.arrow_upward, Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, double amount, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat('#,###').format(amount),
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard(List<TransactionEntity> transactions, DateTime start, DateTime end) {
    if (transactions.isEmpty) {
      return GlassCard(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.show_chart, size: 64, color: Colors.white.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(
              'Нет данных для графика',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Группировка по дням
    final Map<DateTime, double> dailyExpenses = {};
    for (var t in transactions) {
      if (t.type == TransactionType.expense) {
        final day = DateTime(t.date.year, t.date.month, t.date.day);
        dailyExpenses[day] = (dailyExpenses[day] ?? 0) + t.amount;
      }
    }

    final spots = dailyExpenses.entries.map((e) {
      final daysSinceStart = e.key.difference(start).inDays.toDouble();
      return FlSpot(daysSinceStart, e.value);
    }).toList()..sort((a, b) => a.x.compareTo(b.x));

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Динамика расходов',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 5000,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) => Text(
                        NumberFormat.compact().format(value),
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7A3DF2), Color(0xFFE91E63)],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF7A3DF2),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF7A3DF2).withOpacity(0.3),
                          const Color(0xFF7A3DF2).withOpacity(0.0),
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
    );
  }

  Widget _buildAIInsights(double income, double expense, double balance) {
    String insight;
    IconData icon;
    Color color;

    if (balance >= income * 0.3) {
      insight = '🎉 Отличная работа! Вы сэкономили ${((balance / income) * 100).toStringAsFixed(0)}% от дохода';
      icon = Icons.emoji_events;
      color = const Color(0xFF4CAF50);
    } else if (balance >= 0) {
      insight = '👍 Хороший баланс. Рекомендую откладывать минимум 20% от дохода';
      icon = Icons.thumb_up;
      color = const Color(0xFF2196F3);
    } else {
      insight = '⚠️ Расходы превышают доходы на ${NumberFormat('#,###').format(balance.abs())} сом. Пересмотрите бюджет';
      icon = Icons.warning;
      color = const Color(0xFFFF9800);
    }

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Инсайт',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(List<MapEntry<String, double>> categories, double totalExpense) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Расходы по категориям',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...categories.take(5).map((entry) {
            final percentage = (entry.value / totalExpense * 100);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        '${NumberFormat('#,###').format(entry.value)} сом',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage / 100,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: GlassTheme.accentGradient,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7A3DF2).withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFinancialHealthScore(double income, double expense) {
    final score = income > 0 ? ((1 - (expense / income)).clamp(0.0, 1.0) * 100).toInt() : 0;
    Color scoreColor;
    String scoreLabel;

    if (score >= 80) {
      scoreColor = const Color(0xFF4CAF50);
      scoreLabel = 'Отлично';
    } else if (score >= 60) {
      scoreColor = const Color(0xFF2196F3);
      scoreLabel = 'Хорошо';
    } else if (score >= 40) {
      scoreColor = const Color(0xFFFF9800);
      scoreLabel = 'Средне';
    } else {
      scoreColor = const Color(0xFFE53935);
      scoreLabel = 'Требует внимания';
    }

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Финансовое здоровье',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(scoreColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    scoreLabel,
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
