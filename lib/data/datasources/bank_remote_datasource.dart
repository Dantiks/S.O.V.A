import 'package:dio/dio.dart';
import 'package:finer/domain/entities/bank_account_entity.dart';
import 'package:finer/domain/entities/transaction_entity.dart';

abstract class BankRemoteDataSource {
  Future<List<BankAccountEntity>> getAccounts(String userId);
  Future<BankAccountEntity> addAccount(BankAccountEntity account);
  Future<void> syncAccount(String accountId);
  Future<List<TransactionEntity>> getTransactions(String accountId, {int limit = 50});
}

class BankRemoteDataSourceImpl implements BankRemoteDataSource {
  final Dio _dio;

  BankRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  @override
  Future<List<BankAccountEntity>> getAccounts(String userId) async {
    try {
      // TODO: Implement actual API call
      // For now, return mock data
      return _getMockAccounts(userId);
    } catch (e) {
      throw Exception('Failed to fetch accounts: $e');
    }
  }

  @override
  Future<BankAccountEntity> addAccount(BankAccountEntity account) async {
    try {
      // TODO: Implement actual API call to add account
      return account;
    } catch (e) {
      throw Exception('Failed to add account: $e');
    }
  }

  @override
  Future<void> syncAccount(String accountId) async {
    try {
      // TODO: Implement account synchronization with bank API
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      throw Exception('Failed to sync account: $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactions(
    String accountId, {
    int limit = 50,
  }) async {
    try {
      // TODO: Implement actual API call
      return _getMockTransactions(accountId, limit);
    } catch (e) {
      throw Exception('Failed to fetch transactions: $e');
    }
  }

  // Mock data for development
  List<BankAccountEntity> _getMockAccounts(String userId) {
    return [
      BankAccountEntity(
        id: '1',
        userId: userId,
        bankName: 'Optima Bank',
        accountNumber: '**** 1234',
        accountType: 'Текущий счет',
        balance: 45250.00,
        currency: 'KGS',
        accountHolderName: 'Иван Иванов',
        isPrimary: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        lastSyncedAt: DateTime.now(),
      ),
      BankAccountEntity(
        id: '2',
        userId: userId,
        bankName: 'KICB',
        accountNumber: '**** 5678',
        accountType: 'Сберегательный счет',
        balance: 80200.00,
        currency: 'KGS',
        accountHolderName: 'Иван Иванов',
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        lastSyncedAt: DateTime.now(),
      ),
    ];
  }

  List<TransactionEntity> _getMockTransactions(String accountId, int limit) {
    final now = DateTime.now();
    return [
      TransactionEntity(
        id: '1',
        accountId: accountId,
        userId: 'user1',
        type: TransactionType.expense,
        amount: 2450.00,
        currency: 'KGS',
        category: 'Продукты',
        date: now,
        status: TransactionStatus.completed,
        description: 'Супермаркет "Народный"',
        merchant: 'Народный',
        createdAt: now,
      ),
      TransactionEntity(
        id: '2',
        accountId: accountId,
        userId: 'user1',
        type: TransactionType.income,
        amount: 85000.00,
        currency: 'KGS',
        category: 'Зарплата',
        date: now.subtract(const Duration(days: 1)),
        status: TransactionStatus.completed,
        description: 'Зарплата за октябрь',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TransactionEntity(
        id: '3',
        accountId: accountId,
        userId: 'user1',
        type: TransactionType.expense,
        amount: 850.00,
        currency: 'KGS',
        category: 'Рестораны',
        date: now.subtract(const Duration(days: 1)),
        status: TransactionStatus.completed,
        description: 'Кафе "Coffeeshop"',
        merchant: 'Coffeeshop',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }
}
