import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/data/datasources/bank_remote_datasource.dart';
import 'package:sova/data/repositories/bank_repository_impl.dart';
import 'package:sova/domain/entities/bank_account_entity.dart';
import 'package:sova/domain/entities/transaction_entity.dart';
import 'package:sova/domain/repositories/bank_repository.dart';

// Repository Provider
final bankRepositoryProvider = Provider<BankRepository>((ref) {
  return BankRepositoryImpl(BankRemoteDataSourceImpl());
});

// Accounts Provider
final accountsProvider = FutureProvider.family<List<BankAccountEntity>, String>(
  (ref, userId) async {
    final repository = ref.watch(bankRepositoryProvider);
    final result = await repository.getAccounts(userId);
    return result.dataOrNull ?? [];
  },
);

// Total Balance Provider
final totalBalanceProvider = FutureProvider.family<double, String>(
  (ref, userId) async {
    final repository = ref.watch(bankRepositoryProvider);
    final result = await repository.getTotalBalance(userId);
    return result.dataOrNull ?? 0.0;
  },
);

// Transactions Provider
final transactionsProvider = FutureProvider.family<List<TransactionEntity>, String>(
  (ref, accountId) async {
    final repository = ref.watch(bankRepositoryProvider);
    final result = await repository.getTransactions(accountId);
    return result.dataOrNull ?? [];
  },
);

// Bank Controller
class BankController extends StateNotifier<AsyncValue<List<BankAccountEntity>>> {
  final BankRepository _repository;
  final String userId;

  BankController(this._repository, this.userId) : super(const AsyncValue.loading()) {
    loadAccounts();
  }

  Future<void> loadAccounts() async {
    state = const AsyncValue.loading();
    final result = await _repository.getAccounts(userId);
    
    result.when(
      success: (accounts) => state = AsyncValue.data(accounts),
      failure: (message, code) => state = AsyncValue.error(
        message,
        StackTrace.current,
      ),
    );
  }

  Future<void> addAccount(BankAccountEntity account) async {
    final result = await _repository.addAccount(account);
    
    result.when(
      success: (_) => loadAccounts(),
      failure: (message, code) => state = AsyncValue.error(
        message,
        StackTrace.current,
      ),
    );
  }

  Future<void> syncAccount(String accountId) async {
    await _repository.syncAccount(accountId);
    await loadAccounts();
  }
}

final bankControllerProvider = StateNotifierProvider.family<
    BankController,
    AsyncValue<List<BankAccountEntity>>,
    String>((ref, userId) {
  final repository = ref.watch(bankRepositoryProvider);
  return BankController(repository, userId);
});
