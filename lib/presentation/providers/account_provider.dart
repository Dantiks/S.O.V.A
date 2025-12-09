import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/domain/entities/bank_account_entity.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Провайдер для управления банковскими счетами с Hive
class AccountNotifier extends StateNotifier<List<BankAccountEntity>> {
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
          .map((data) => BankAccountEntity.fromJson(Map<String, dynamic>.from(data)))
          .toList();
      state = accounts;
    } catch (e) {
      print('Ошибка загрузки счетов: $e');
      state = [];
    }
  }

  /// Добавление нового счета
  Future<void> addAccount(BankAccountEntity account) async {
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
  Future<void> updateAccount(BankAccountEntity account) async {
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
  List<BankAccountEntity> getByBank(String bankName) {
    return state.where((a) => a.bankName == bankName).toList();
  }
  
  /// Получение активных счетов
  List<BankAccountEntity> getActiveAccounts() {
    return state.where((a) => a.isActive).toList();
  }
  
  /// Получение основного счета
  BankAccountEntity? getPrimaryAccount() {
    try {
      return state.firstWhere((a) => a.isPrimary);
    } catch (e) {
      return null;
    }
  }
  
  /// Установить счет как основной
  Future<void> setPrimaryAccount(String accountId) async {
    try {
      // Снять флаг primary со всех счетов
      for (final account in state) {
        if (account.isPrimary) {
          await updateAccount(account.copyWith(isPrimary: false));
        }
      }
      
      // Установить флаг primary для выбранного счета
      final account = state.firstWhere((a) => a.id == accountId);
      await updateAccount(account.copyWith(isPrimary: true));
    } catch (e) {
      print('Ошибка установки основного счета: $e');
      rethrow;
    }
  }

  /// Обновление баланса счета
  Future<void> updateBalance(String accountId, double newBalance) async {
    final account = state.firstWhere((a) => a.id == accountId);
    await updateAccount(account.copyWith(balance: newBalance));
  }
}

final accountProvider =
    StateNotifierProvider<AccountNotifier, List<BankAccountEntity>>((ref) {
  return AccountNotifier();
});
