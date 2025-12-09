import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:finer/presentation/providers/transaction_provider.dart';
import 'package:finer/domain/entities/transaction_entity.dart';
import 'package:finer/presentation/screens/transactions/add_transaction_screen.dart';
import 'package:finer/presentation/screens/transactions/search_transactions_screen.dart';
import 'package:intl/intl.dart';

enum TransactionFilter { all, income, expense }
enum TransactionSort { dateDesc, dateAsc, amountDesc, amountAsc }

class AllTransactionsScreen extends ConsumerStatefulWidget {
  const AllTransactionsScreen({super.key});

  @override
  ConsumerState<AllTransactionsScreen> createState() => _AllTransactionsScreenState();
}

class _AllTransactionsScreenState extends ConsumerState<AllTransactionsScreen> {
  TransactionFilter _filter = TransactionFilter.all;
  TransactionSort _sort = TransactionSort.dateDesc;

  @override
  Widget build(BuildContext context) {
    final allTransactions = ref.watch(transactionProvider);
    
    // Apply filter
    var filteredTransactions = allTransactions.where((t) {
      switch (_filter) {
        case TransactionFilter.income:
          return t.type == TransactionType.income;
        case TransactionFilter.expense:
          return t.type == TransactionType.expense;
        case TransactionFilter.all:
          return true;
      }
    }).toList();

    // Apply sort
    filteredTransactions.sort((a, b) {
      switch (_sort) {
        case TransactionSort.dateDesc:
          return b.date.compareTo(a.date);
        case TransactionSort.dateAsc:
          return a.date.compareTo(b.date);
        case TransactionSort.amountDesc:
          return b.amount.compareTo(a.amount);
        case TransactionSort.amountAsc:
          return a.amount.compareTo(b.amount);
      }
    });

    // Group by date
    final groupedTransactions = _groupByDate(filteredTransactions);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Все транзакции',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SearchTransactionsScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
                        );
                        if (result == true) {
                          ref.read(transactionProvider.notifier).loadTransactions();
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Filters
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _buildFilterChip('Все', TransactionFilter.all),
                            const SizedBox(width: 4),
                            _buildFilterChip('Доходы', TransactionFilter.income),
                            const SizedBox(width: 4),
                            _buildFilterChip('Расходы', TransactionFilter.expense),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    WaterRippleButton(
                      onPressed: _showSortMenu,
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.sort, color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Statistics
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        'Всего',
                        filteredTransactions.length.toString(),
                        Icons.receipt_long,
                        const Color(0xFF7A3DF2),
                      ),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                      _buildStat(
                        'Доходы',
                        NumberFormat.compact().format(
                          filteredTransactions
                              .where((t) => t.type == TransactionType.income)
                              .fold(0.0, (sum, t) => sum + t.amount),
                        ),
                        Icons.arrow_downward,
                        Colors.green,
                      ),
                      Container(width: 1, height: 40, color: Colors.white.withOpacity(0.2)),
                      _buildStat(
                        'Расходы',
                        NumberFormat.compact().format(
                          filteredTransactions
                              .where((t) => t.type == TransactionType.expense)
                              .fold(0.0, (sum, t) => sum + t.amount),
                        ),
                        Icons.arrow_upward,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Transactions List
              Expanded(
                child: filteredTransactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Colors.white.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Нет транзакций',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: groupedTransactions.length,
                        itemBuilder: (context, index) {
                          final date = groupedTransactions.keys.elementAt(index);
                          final transactions = groupedTransactions[date]!;
                          return _buildDateGroup(date, transactions);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionFilter filter) {
    final isSelected = _filter == filter;
    return Expanded(
      child: WaterRippleButton(
        onPressed: () => setState(() => _filter = filter),
        padding: const EdgeInsets.symmetric(vertical: 10),
        gradient: isSelected ? GlassTheme.accentGradient : null,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDateGroup(String date, List<TransactionEntity> transactions) {
    final total = transactions.fold(0.0, (sum, t) {
      return sum + (t.type == TransactionType.income ? t.amount : -t.amount);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${total >= 0 ? '+' : ''}${NumberFormat('#,###').format(total)} сом',
                style: TextStyle(
                  color: total >= 0 ? Colors.green : Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ...transactions.map((t) => _buildTransactionCard(t)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTransactionCard(TransactionEntity transaction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(transaction.id),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: const Color(0xFF1a1a2e),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Удалить транзакцию?', style: TextStyle(color: Colors.white)),
              content: const Text(
                'Это действие нельзя отменить',
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) {
          ref.read(transactionProvider.notifier).deleteTransaction(transaction.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Транзакция удалена')),
          );
        },
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(12),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddTransactionScreen(transaction: transaction),
              ),
            );
            if (result == true) {
              ref.read(transactionProvider.notifier).loadTransactions();
            }
          },
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: transaction.type == TransactionType.income
                      ? const LinearGradient(colors: [Colors.green, Color(0xFF2E7D32)])
                      : const LinearGradient(colors: [Colors.red, Color(0xFFC62828)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  transaction.type == TransactionType.income
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.categoryId,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (transaction.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        transaction.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '${transaction.type == TransactionType.income ? '+' : '-'}${NumberFormat('#,###').format(transaction.amount)}',
                style: TextStyle(
                  color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<TransactionEntity>> _groupByDate(List<TransactionEntity> transactions) {
    final Map<String, List<TransactionEntity>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final transaction in transactions) {
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      String dateKey;
      if (transactionDate == today) {
        dateKey = 'Сегодня';
      } else if (transactionDate == yesterday) {
        dateKey = 'Вчера';
      } else if (transactionDate.isAfter(today.subtract(const Duration(days: 7)))) {
        dateKey = DateFormat('EEEE', 'ru').format(transaction.date);
      } else {
        dateKey = DateFormat('d MMMM', 'ru').format(transaction.date);
      }

      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return grouped;
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1a1a2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Сортировка',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Сначала новые', TransactionSort.dateDesc, Icons.arrow_downward),
            _buildSortOption('Сначала старые', TransactionSort.dateAsc, Icons.arrow_upward),
            _buildSortOption('Сумма (убывание)', TransactionSort.amountDesc, Icons.trending_down),
            _buildSortOption('Сумма (возрастание)', TransactionSort.amountAsc, Icons.trending_up),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, TransactionSort sort, IconData icon) {
    final isSelected = _sort == sort;
    return ListTile(
      leading: Icon(icon, color: isSelected ? const Color(0xFF7A3DF2) : Colors.white),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF7A3DF2) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF7A3DF2)) : null,
      onTap: () {
        setState(() => _sort = sort);
        Navigator.pop(context);
      },
    );
  }
}
