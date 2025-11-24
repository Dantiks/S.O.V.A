import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/domain/entities/account_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Провайдер для управления банковскими счетами с Hive
class AccountNotifier extends StateNotifier<List<AccountEntity>> {
  static const String _boxName = 'accounts';
  late Box<Map> _box;

  AccountNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    try {
      _box = await Hive.openBox<Map>(_boxName);
      await loadAccounts();
    } catch (e) {
      print('Ошибка инициализации счетов: $e');
    }
  }

  /// Загрузка счетов из Hive
  Future<void> loadAccounts() async {
    try {
      final accounts = _box.values
          .map((data) => AccountEntity.fromJson(Map<String, dynamic>.from(data)))
          .toList();
      state = accounts;
    } catch (e) {
      print('Ошибка загрузки счетов: $e');
      state = [];
    }
  }

  /// Добавление нового счета
  Future<void> addAccount(AccountEntity account) async {
    try {
      final id = account.id.isEmpty ? _uuid.v4() : account.id;
      final newAccount = account.copyWith(id: id);
      
      await _box.put(id, newAccount.toJson());
      state = [...state, newAccount];
    } catch (e) {
      print('Ошибка добавления счета: $e');
      rethrow;
    }
  }

  /// Обновление счета
  Future<void> updateAccount(AccountEntity account) async {
    try {
      await _box.put(account.id, account.toJson());
      state = state
          .map((a) => a.id == account.id ? account : a)
          .toList();
    } catch (e) {
      print('Ошибка обновления счета: $e');
      rethrow;
    }
  }

  /// Удаление счета
  Future<void> deleteAccount(String accountId) async {
    try {
      await _box.delete(accountId);
      state = state.where((a) => a.id != accountId).toList();
    } catch (e) {
      print('Ошибка удаления счета: $e');
      rethrow;
    }
  }

  /// Получение общего баланса
  double getTotalBalance() {
    return state.fold(0.0, (sum, account) => sum + account.balance);
  }

  /// Получение счетов по банку
  List<AccountEntity> getByBank(String bankId) {
    return state.where((a) => a.bankId == bankId).toList();
  }

  /// Обновление баланса счета
  Future<void> updateBalance(String accountId, double newBalance) async {
    final account = state.firstWhere((a) => a.id == accountId);
    await updateAccount(account.copyWith(balance: newBalance));
  }
}

final accountProvider =
    StateNotifierProvider<AccountNotifier, List<AccountEntity>>((ref) {
  return AccountNotifier();
});
