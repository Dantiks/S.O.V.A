import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:finer/domain/entities/budget_entity.dart';
import 'package:finer/domain/entities/category_entity.dart';
import 'package:finer/presentation/providers/budget_provider.dart';
import 'package:finer/presentation/screens/budgets/add_budget_screen.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  @override
  void initState() {
    super.initState();
    // Пересчитать все бюджеты при открытии экрана
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetProvider.notifier).recalculateAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final budgets = ref.watch(budgetProvider);
    final activeBudgets = budgets.where((b) => b.isActive).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Бюджеты',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddBudgetScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)],
          ),
        ),
        child: SafeArea(
          child: activeBudgets.isEmpty
              ? _buildEmptyState()
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Общая статистика
                    _buildOverallStats(activeBudgets),
                    const SizedBox(height: 24),

                    // Заголовок
                    Text(
                      'Бюджеты по категориям',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Список бюджетов
                    ...activeBudgets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final budget = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildBudgetCard(budget, index),
                      );
                    }),

                    const SizedBox(height: 80),
                  ],
                ),
        ),
      ),
      floatingActionButton: activeBudgets.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddBudgetScreen(),
                  ),
                );
              },
              backgroundColor: const Color(0xFF7A3DF2),
              icon: const Icon(Icons.add),
              label: const Text('Добавить бюджет'),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF7A3DF2).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Color(0xFF7A3DF2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Нет бюджетов',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Создайте бюджеты для контроля расходов\nи получайте уведомления о превышении',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddBudgetScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Создать первый бюджет'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A3DF2),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
    );
  }

  Widget _buildOverallStats(List<BudgetEntity> budgets) {
    final totalBudget = budgets.fold<double>(0, (sum, b) => sum + b.amount);
    final totalSpent = budgets.fold<double>(0, (sum, b) => sum + b.spent);
    final percentage = totalBudget > 0 ? (totalSpent / totalBudget * 100).toInt() : 0;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF7A3DF2), Color(0xFF5A2DB2)],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF7A3DF2).withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Общий бюджет',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalBudget.toStringAsFixed(0)} ₸',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Потрачено',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${totalSpent.toStringAsFixed(0)} ₸',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Осталось',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(totalBudget - totalSpent).toStringAsFixed(0)} ₸',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (totalSpent / totalBudget).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage >= 100
                    ? Colors.red
                    : percentage >= 80
                        ? Colors.orange
                        : Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% использовано',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildBudgetCard(BudgetEntity budget, int index) {
    final notifier = ref.read(budgetProvider.notifier);
    final progress = notifier.getProgress(budget);
    final percentage = notifier.getPercentage(budget);
    final remaining = notifier.getRemaining(budget);
    final daysLeft = notifier.getDaysRemaining(budget);
    final isExceeded = notifier.isExceeded(budget);
    final isWarning = notifier.isWarning(budget);

    Color progressColor;
    if (isExceeded) {
      progressColor = Colors.red;
    } else if (isWarning) {
      progressColor = Colors.orange;
    } else {
      progressColor = const Color(0xFF7A3DF2);
    }

    return GestureDetector(
      onTap: () {
        // TODO: Открыть детали бюджета
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(budget.categoryId),
                    color: progressColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCategoryName(budget.categoryId),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getPeriodText(budget.period),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isExceeded)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '⚠️ Превышен',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (isWarning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '⚠️ Близко',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${budget.spent.toStringAsFixed(0)} ₸ / ${budget.amount.toStringAsFixed(0)} ₸',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Colors.white.withOpacity(0.5),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Осталось: ${remaining.toStringAsFixed(0)} ₸ ($daysLeft ${_getDaysWord(daysLeft)})',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.2, end: 0);
  }

  IconData _getCategoryIcon(String categoryId) {
    // TODO: Получить реальную иконку из категории
    switch (categoryId) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.local_hospital;
      default:
        return Icons.category;
    }
  }

  String _getCategoryName(String categoryId) {
    // TODO: Получить реальное название из категории
    switch (categoryId) {
      case 'food':
        return 'Продукты';
      case 'transport':
        return 'Транспорт';
      case 'shopping':
        return 'Покупки';
      case 'entertainment':
        return 'Развлечения';
      case 'health':
        return 'Здоровье';
      default:
        return 'Другое';
    }
  }

  String _getPeriodText(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.daily:
        return 'Дневной';
      case BudgetPeriod.weekly:
        return 'Недельный';
      case BudgetPeriod.monthly:
        return 'Месячный';
      case BudgetPeriod.yearly:
        return 'Годовой';
    }
  }

  String _getDaysWord(int days) {
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }
}
