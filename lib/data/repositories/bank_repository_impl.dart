import 'package:sova/core/utils/result.dart';
import 'package:sova/data/datasources/bank_remote_datasource.dart';
import 'package:sova/domain/entities/bank_account_entity.dart';
import 'package:sova/domain/entities/transaction_entity.dart';
import 'package:sova/domain/repositories/bank_repository.dart';

class BankRepositoryImpl implements BankRepository {
  final BankRemoteDataSource _remoteDataSource;

  BankRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<BankAccountEntity>>> getAccounts(String userId) async {
    try {
      final accounts = await _remoteDataSource.getAccounts(userId);
      return Result.success(accounts);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<BankAccountEntity>> addAccount(BankAccountEntity account) async {
    try {
      final newAccount = await _remoteDataSource.addAccount(account);
      return Result.success(newAccount);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<void>> syncAccount(String accountId) async {
    try {
      await _remoteDataSource.syncAccount(accountId);
      return const Result.success(null);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getTransactions(
    String accountId, {
    int limit = 50,
  }) async {
    try {
      final transactions = await _remoteDataSource.getTransactions(
        accountId,
        limit: limit,
      );
      return Result.success(transactions);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<double>> getTotalBalance(String userId) async {
    try {
      final accountsResult = await getAccounts(userId);
      
      return accountsResult.when(
        success: (accounts) {
          final total = accounts.fold<double>(
            0.0,
            (sum, account) => sum + account.balance,
          );
          return Result.success(total);
        },
        failure: (message, code) => Result.failure(message, code: code),
      );
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
