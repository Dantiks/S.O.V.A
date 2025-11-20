import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/domain/entities/bank_account_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sova/presentation/providers/transaction_provider.dart';

/// Провайдер для управления банковскими счетами
class AccountNotifier extends StateNotifier<List<BankAccountEntity>> {
  final FirebaseFirestore _firestore;
  final String userId;

  AccountNotifier(this._firestore, this.userId) : super([]) {
    loadAccounts();
  }

  /// Загрузка счетов
  Future<void> loadAccounts() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .get();

      state = snapshot.docs
          .map((doc) => BankAccountEntity.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    } catch (e) {
      print('Ошибка загрузки счетов: $e');
    }
  }

  /// Добавление счета
  Future<void> addAccount(BankAccountEntity account) async {
    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .add(account.toJson());

      final newAccount = account.copyWith(id: docRef.id);
      state = [...state, newAccount];
    } catch (e) {
      print('Ошибка добавления счета: $e');
      rethrow;
    }
  }

  /// Обновление счета
  Future<void> updateAccount(BankAccountEntity account) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(account.id)
          .update(account.toJson());

      state = state.map((a) => a.id == account.id ? account : a).toList();
    } catch (e) {
      print('Ошибка обновления счета: $e');
      rethrow;
    }
  }

  /// Удаление счета
  Future<void> deleteAccount(String accountId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('accounts')
          .doc(accountId)
          .delete();

      state = state.where((a) => a.id != accountId).toList();
    } catch (e) {
      print('Ошибка удаления счета: $e');
      rethrow;
    }
  }

  /// Получение общего баланса всех счетов
  double getTotalBalance() {
    return state.fold(0.0, (sum, account) => sum + account.balance);
  }

  /// Получение счетов по банку
  List<BankAccountEntity> getByBank(String bankId) {
    return state.where((a) => a.bankId == bankId).toList();
  }
}

final accountProvider =
    StateNotifierProvider<AccountNotifier, List<BankAccountEntity>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  return AccountNotifier(FirebaseFirestore.instance, userId);
});
