import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/domain/entities/recurring_transaction_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// Провайдер для текущего пользователя
final currentUserIdProvider = Provider<String>((ref) => 'demo_user');

/// Провайдер для управления регулярными платежами с Hive
class RecurringNotifier extends StateNotifier<List<RecurringTransactionEntity>> {
  static const String _boxName = 'recurring';
  late Box<Map> _box;

  RecurringNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<Map>(_boxName);
      await loadRecurring();
    } catch (e) {
      print('Ошибка инициализации регулярных платежей: $e');
    }
  }

  /// Загрузка регулярных платежей из Hive
  Future<void> loadRecurring() async {
    try {
      final recurring = _box.values
          .map((data) => RecurringTransactionEntity.fromJson(Map<String, dynamic>.from(data)))
          .toList();
      state = recurring;
    } catch (e) {
      print('Ошибка загрузки регулярных платежей: $e');
      state = [];
    }
  }

  /// Добавление регулярного платежа
  Future<void> addRecurring(RecurringTransactionEntity recurring) async {
    try {
      final id = recurring.id.isEmpty ? _uuid.v4() : recurring.id;
      final newRecurring = recurring.copyWith(
        id: id,
        nextDueDate: recurring.calculateNextDueDate(),
      );
      
      await _box.put(id, newRecurring.toJson());
      state = [...state, newRecurring];
    } catch (e) {
      print('Ошибка добавления регулярного платежа: $e');
      rethrow;
    }
  }

  /// Обновление регулярного платежа
  Future<void> updateRecurring(RecurringTransactionEntity recurring) async {
    try {
      await _box.put(recurring.id, recurring.toJson());
      state = state
          .map((r) => r.id == recurring.id ? recurring : r)
          .toList();
    } catch (e) {
      print('Ошибка обновления регулярного платежа: $e');
      rethrow;
    }
  }

  /// Удаление регулярного платежа
  Future<void> deleteRecurring(String recurringId) async {
    try {
      await _box.delete(recurringId);
      state = state.where((r) => r.id != recurringId).toList();
    } catch (e) {
      print('Ошибка удаления регулярного платежа: $e');
      rethrow;
    }
  }

  /// Получение активных регулярных платежей
  List<RecurringTransactionEntity> getActive() {
    return state.where((r) => r.isActive).toList();
  }

  /// Получение регулярных платежей по частоте
  List<RecurringTransactionEntity> getByFrequency(RecurringFrequency frequency) {
    return state.where((r) => r.frequency == frequency).toList();
  }

  /// Расчет следующей даты платежа
  DateTime getNextPaymentDate(RecurringTransactionEntity recurring) {
    return recurring.nextDueDate ?? recurring.calculateNextDueDate();
  }

  /// Расчет общей суммы регулярных платежей за месяц
  double getMonthlyTotal() {
    return state.where((r) => r.isActive).fold(0.0, (sum, r) {
      switch (r.frequency) {
        case RecurringFrequency.daily:
          return sum + (r.amount * 30);
        case RecurringFrequency.weekly:
          return sum + (r.amount * 4);
        case RecurringFrequency.biweekly:
          return sum + (r.amount * 2);
        case RecurringFrequency.monthly:
          return sum + r.amount;
        case RecurringFrequency.quarterly:
          return sum + (r.amount / 3);
        case RecurringFrequency.yearly:
          return sum + (r.amount / 12);
      }
    });
  }

  /// Получение платежей, которые должны быть выполнены сегодня
  List<RecurringTransactionEntity> getDueToday() {
    return state.where((r) => r.isActive && r.isDueToday).toList();
  }

  /// Получение платежей, которые должны быть выполнены в ближайшие N дней
  List<RecurringTransactionEntity> getDueInDays(int days) {
    return state.where((r) {
      if (!r.isActive || r.nextDueDate == null) return false;
      final daysUntil = r.daysUntilDue;
      return daysUntil >= 0 && daysUntil <= days;
    }).toList();
  }

  /// Отметить платеж как выполненный
  Future<void> markAsProcessed(String recurringId) async {
    try {
      final recurring = state.firstWhere((r) => r.id == recurringId);
      final now = DateTime.now();
      final updated = recurring.copyWith(
        lastProcessedDate: now,
        nextDueDate: recurring.calculateNextDueDate(),
      );
      await updateRecurring(updated);
    } catch (e) {
      print('Ошибка отметки платежа как выполненного: $e');
      rethrow;
    }
  }

  /// Переключить активность платежа
  Future<void> toggleActive(String recurringId) async {
    try {
      final recurring = state.firstWhere((r) => r.id == recurringId);
      final updated = recurring.copyWith(isActive: !recurring.isActive);
      await updateRecurring(updated);
    } catch (e) {
      print('Ошибка переключения активности: $e');
      rethrow;
    }
  }

  /// Получить статистику по регулярным платежам
  Map<String, dynamic> getStatistics() {
    final active = state.where((r) => r.isActive).length;
    final inactive = state.where((r) => !r.isActive).length;
    final dueToday = getDueToday().length;
    final dueThisWeek = getDueInDays(7).length;
    final monthlyTotal = getMonthlyTotal();

    return {
      'total': state.length,
      'active': active,
      'inactive': inactive,
      'dueToday': dueToday,
      'dueThisWeek': dueThisWeek,
      'monthlyTotal': monthlyTotal,
    };
  }
}

final recurringProvider =
    StateNotifierProvider<RecurringNotifier, List<RecurringTransactionEntity>>((ref) {
  return RecurringNotifier();
});
