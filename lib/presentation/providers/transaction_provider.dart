import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/domain/entities/transaction_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Провайдер для управления транзакциями
class TransactionNotifier extends StateNotifier<List<TransactionEntity>> {
  final FirebaseFirestore _firestore;
  final String userId;

  TransactionNotifier(this._firestore, this.userId) : super([]) {
    loadTransactions();
  }

  /// Загрузка транзакций из Firestore
  Future<void> loadTransactions() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      state = snapshot.docs
          .map((doc) => TransactionEntity.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Ошибка загрузки транзакций: $e');
    }
  }

  /// Добавление новой транзакции
  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .add(transaction.toJson());

      final newTransaction = transaction.copyWith(id: docRef.id);
      state = [newTransaction, ...state];
    } catch (e) {
      print('Ошибка добавления транзакции: $e');
      rethrow;
    }
  }

  /// Обновление транзакции
  Future<void> updateTransaction(TransactionEntity transaction) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id)
          .update(transaction.toJson());

      state = state
          .map((t) => t.id == transaction.id ? transaction : t)
          .toList();
    } catch (e) {
      print('Ошибка обновления транзакции: $e');
      rethrow;
    }
  }

  /// Удаление транзакции
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transactionId)
          .delete();

      state = state.where((t) => t.id != transactionId).toList();
    } catch (e) {
      print('Ошибка удаления транзакции: $e');
      rethrow;
    }
  }

  /// Получение транзакций по категории
  List<TransactionEntity> getByCategory(String categoryId) {
    return state.where((t) => t.categoryId == categoryId).toList();
  }

  /// Получение транзакций по счету
  List<TransactionEntity> getByAccount(String accountId) {
    return state.where((t) => t.accountId == accountId).toList();
  }

  /// Получение транзакций за период
  List<TransactionEntity> getByDateRange(DateTime start, DateTime end) {
    return state.where((t) {
      return t.date.isAfter(start) && t.date.isBefore(end);
    }).toList();
  }

  /// Расчет общего баланса
  double getTotalBalance() {
    return state.fold(0.0, (sum, t) {
      return sum + (t.type == TransactionType.income ? t.amount : -t.amount);
    });
  }

  /// Расчет доходов за период
  double getIncomeForPeriod(DateTime start, DateTime end) {
    return getByDateRange(start, end)
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Расчет расходов за период
  double getExpenseForPeriod(DateTime start, DateTime end) {
    return getByDateRange(start, end)
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return TransactionNotifier(FirebaseFirestore.instance, userId);
});

/// Провайдер текущего ID пользователя
final currentUserIdProvider = Provider<String>((ref) {
  // TODO: Получить из auth provider
  return 'demo_user';
});
