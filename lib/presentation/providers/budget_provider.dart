import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finer/domain/entities/budget_entity.dart';
import 'package:finer/domain/entities/transaction_entity.dart';
import 'package:finer/presentation/providers/transaction_provider.dart';
import 'package:finer/core/services/notification_service.dart';
import 'package:uuid/uuid.dart';

final budgetProvider = StateNotifierProvider<BudgetNotifier, List<BudgetEntity>>(
  (ref) => BudgetNotifier(ref),
);

class BudgetNotifier extends StateNotifier<List<BudgetEntity>> {
  final Ref ref;
  late Box<Map<dynamic, dynamic>> _box;
  static const String _boxName = 'budgets';
  final _uuid = const Uuid();

  BudgetNotifier(this.ref) : super([]) {
    _initBox();
  }

  Future<void> _initBox() async {
    _box = await Hive.openBox<Map<dynamic, dynamic>>(_boxName);
    await _loadBudgets();
  }

  /// Загрузить бюджеты из Hive
  Future<void> _loadBudgets() async {
    try {
      final items = _box.values
          .map((json) => BudgetEntity.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      state = items;
      print('✅ Loaded ${items.length} budgets');
    } catch (e) {
      print('❌ Error loading budgets: $e');
      state = [];
    }
  }

  /// Добавить бюджет
  Future<void> add(BudgetEntity budget) async {
    try {
      final newBudget = budget.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _box.put(newBudget.id, newBudget.toJson());
      state = [...state, newBudget];
      print('✅ Budget added: ${newBudget.categoryId}');
    } catch (e) {
      print('❌ Error adding budget: $e');
    }
  }

  /// Обновить бюджет
  Future<void> update(BudgetEntity budget) async {
    try {
      final updatedBudget = budget.copyWith(updatedAt: DateTime.now());
      await _box.put(budget.id, updatedBudget.toJson());
      
      state = [
        for (final item in state)
          if (item.id == budget.id) updatedBudget else item
      ];
      print('✅ Budget updated: ${budget.id}');
    } catch (e) {
      print('❌ Error updating budget: $e');
    }
  }

  /// Удалить бюджет
  Future<void> delete(String id) async {
    try {
      await _box.delete(id);
      state = state.where((item) => item.id != id).toList();
      print('✅ Budget deleted: $id');
    } catch (e) {
      print('❌ Error deleting budget: $e');
    }
  }

  /// Получить бюджет по категории
  BudgetEntity? getByCategoryId(String categoryId) {
    try {
      return state.firstWhere(
        (b) => b.categoryId == categoryId && b.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  /// Получить активные бюджеты
  List<BudgetEntity> getActive() {
    return state.where((b) => b.isActive).toList();
  }

  /// Пересчитать потраченную сумму для всех бюджетов
  Future<void> recalculateAll() async {
    final transactions = ref.read(transactionProvider);
    final now = DateTime.now();
    
    for (var budget in state) {
      final spent = _calculateSpent(budget, transactions, now);
      if (spent != budget.spent) {
        await update(budget.copyWith(spent: spent));
        
        // Проверить превышение и отправить уведомление
        await _checkAndNotify(budget.copyWith(spent: spent));
      }
    }
  }

  /// Рассчитать потраченную сумму за период бюджета
  double _calculateSpent(BudgetEntity budget, List<TransactionEntity> transactions, DateTime now) {
    final (start, end) = _getPeriodDates(budget, now);
    
    return transactions
        .where((t) =>
            t.categoryId == budget.categoryId &&
            t.type == TransactionType.expense &&
            t.date.isAfter(start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(end.add(const Duration(days: 1))))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Получить даты начала и конца периода
  (DateTime, DateTime) _getPeriodDates(BudgetEntity budget, DateTime now) {
    switch (budget.period) {
      case BudgetPeriod.daily:
        return (
          DateTime(now.year, now.month, now.day),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        );
      case BudgetPeriod.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return (
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day).add(const Duration(days: 6, hours: 23, minutes: 59)),
        );
      case BudgetPeriod.monthly:
        return (
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case BudgetPeriod.yearly:
        return (
          DateTime(now.year, 1, 1),
          DateTime(now.year, 12, 31, 23, 59, 59),
        );
    }
  }

  /// Проверить превышение и отправить уведомление
  Future<void> _checkAndNotify(BudgetEntity budget) async {
    if (!budget.notifyOnExceed) return;
    
    final percentage = budget.spent / budget.amount;
    final notificationService = NotificationService();
    
    // Уведомление при 75%
    if (percentage >= 0.75 && percentage < 0.8) {
      await notificationService.showNotification(
        id: budget.id.hashCode,
        title: 'Бюджет на 75%',
        body: 'Вы потратили 75% бюджета. Осталось ${(budget.amount - budget.spent).toStringAsFixed(0)}₸',
      );
    }
    
    // Уведомление при warningThreshold (по умолчанию 80%)
    if (percentage >= budget.warningThreshold && percentage < 0.9) {
      await notificationService.showNotification(
        id: budget.id.hashCode + 1,
        title: '⚠️ Близко к лимиту!',
        body: 'Вы потратили ${(percentage * 100).toInt()}% бюджета. Осталось ${(budget.amount - budget.spent).toStringAsFixed(0)}₸',
      );
    }
    
    // Уведомление при 100%
    if (percentage >= 1.0) {
      await notificationService.showNotification(
        id: budget.id.hashCode + 2,
        title: '🚨 Бюджет превышен!',
        body: 'Вы превысили бюджет на ${(budget.spent - budget.amount).toStringAsFixed(0)}₸',
      );
    }
  }

  /// Получить прогресс бюджета (0.0 - 1.0)
  double getProgress(BudgetEntity budget) {
    if (budget.amount <= 0) return 0.0;
    return (budget.spent / budget.amount).clamp(0.0, 1.0);
  }

  /// Получить процент потраченного
  int getPercentage(BudgetEntity budget) {
    return (getProgress(budget) * 100).toInt();
  }

  /// Получить оставшуюся сумму
  double getRemaining(BudgetEntity budget) {
    return (budget.amount - budget.spent).clamp(0.0, double.infinity);
  }

  /// Получить количество дней до конца периода
  int getDaysRemaining(BudgetEntity budget) {
    final now = DateTime.now();
    final (_, end) = _getPeriodDates(budget, now);
    return end.difference(now).inDays;
  }

  /// Проверить превышение
  bool isExceeded(BudgetEntity budget) {
    return budget.spent > budget.amount;
  }

  /// Проверить предупреждение (близко к лимиту)
  bool isWarning(BudgetEntity budget) {
    return getProgress(budget) >= budget.warningThreshold;
  }
}
