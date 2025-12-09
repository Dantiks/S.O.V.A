import 'package:finer/core/utils/result.dart';
import 'package:finer/domain/entities/bank_account_entity.dart';
import 'package:finer/domain/entities/transaction_entity.dart';

abstract class BankRepository {
  Future<Result<List<BankAccountEntity>>> getAccounts(String userId);
  Future<Result<BankAccountEntity>> addAccount(BankAccountEntity account);
  Future<Result<void>> syncAccount(String accountId);
  Future<Result<List<TransactionEntity>>> getTransactions(
    String accountId, {
    int limit = 50,
  });
  Future<Result<double>> getTotalBalance(String userId);
}
