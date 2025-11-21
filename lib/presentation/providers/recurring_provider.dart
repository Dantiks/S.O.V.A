import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/domain/entities/recurring_transaction_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Провайдер для текущего пользователя
final currentUserIdProvider = Provider<String>((ref) => 'demo_user');

/// Провайдер для управления регулярными платежами
class RecurringNotifier extends StateNotifier<List<RecurringTransactionEntity>> {
  final FirebaseFirestore _firestore;
  final String userId;

  RecurringNotifier(this._firestore, this.userId) : super([]) {
    loadRecurring();
  }

  /// Загрузка регулярных платежей
  Future<void> loadRecurring() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recurring')
          .get();

      state = snapshot.docs
          .map((doc) => RecurringTransactionEntity.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Ошибка загрузки регулярных платежей: $e');
    }
  }

  /// Добавление регулярного платежа
  Future<void> addRecurring(RecurringTransactionEntity recurring) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('recurring')
          .add(recurring.toJson());

      final newRecurring = recurring.copyWith(id: docRef.id);
      state = [...state, newRecurring];
    } catch (e) {
      print('Ошибка добавления регулярного платежа: $e');
      rethrow;
    }
  }

  /// Обновление регулярного платежа
  Future<void> updateRecurring(RecurringTransactionEntity recurring) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recurring')
          .doc(recurring.id)
          .update(recurring.toJson());

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
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('recurring')
          .doc(recurringId)
          .delete();

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
}

final recurringProvider =
    StateNotifierProvider<RecurringNotifier, List<RecurringTransactionEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return RecurringNotifier(FirebaseFirestore.instance, userId);
});
