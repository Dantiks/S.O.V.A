import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/domain/entities/transaction_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Провайдер для управления транзакциями с Hive
class TransactionNotifier extends StateNotifier<List<TransactionEntity>> {
  static const String _boxName = 'transactions';
  late Box<Map> _box;

  TransactionNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<Map>(_boxName);
      await loadTransactions();
    } catch (e) {
      print('Ошибка инициализации транзакций: $e');
    }
  }

  /// Загрузка транзакций из Hive
  Future<void> loadTransactions() async {
    try {
      final transactions = _box.values
          .map((data) => TransactionEntity.fromJson(Map<String, dynamic>.from(data)))
          .toList();
      
      // Сортируем по дате (новые сверху)
      transactions.sort((a, b) => b.date.compareTo(a.date));
      state = transactions;
    } catch (e) {
      print('Ошибка загрузки транзакций: $e');
      state = [];
    }
  }

  /// Добавление новой транзакции
  Future<void> addTransaction(TransactionEntity transaction) async {
    try {
      final id = transaction.id.isEmpty ? _uuid.v4() : transaction.id;
      final newTransaction = transaction.copyWith(id: id);
      
      await _box.put(id, newTransaction.toJson());
      state = [newTransaction, ...state];
    } catch (e) {
      print('Ошибка добавления транзакции: $e');
      rethrow;
    }
  }

  /// Обновление транзакции
  Future<void> updateTransaction(TransactionEntity transaction) async {
    try {
      await _box.put(transaction.id, transaction.toJson());
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
      await _box.delete(transactionId);
      state = state.where((t) => t.id != transactionId).toList();
    } catch (e) {
      print('Ошибка удаления транзакции: $e');
      rethrow;
    }
  }

  /// Получение транзакций по типу
  List<TransactionEntity> getByType(TransactionType type) {
    return state.where((t) => t.type == type).toList();
  }

  /// Получение транзакций за период
  List<TransactionEntity> getByPeriod(DateTime start, DateTime end) {
    return state.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
             t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Расчет общего дохода за период
  double getIncomeForPeriod(DateTime start, DateTime end) {
    return getByPeriod(start, end)
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Расчет общих расходов за период
  double getExpenseForPeriod(DateTime start, DateTime end) {
    return getByPeriod(start, end)
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Получение транзакций по категории
  List<TransactionEntity> getByCategory(String categoryId) {
    return state.where((t) => t.categoryId == categoryId).toList();
  }

  /// Получение транзакций по счету
  List<TransactionEntity> getByAccount(String accountId) {
    return state.where((t) => t.accountId == accountId).toList();
  }
}

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionEntity>>((ref) {
  return TransactionNotifier();
});
