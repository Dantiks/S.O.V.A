import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:finer/domain/entities/transaction_entity.dart';

class TransactionCard extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.type == TransactionType.transfer;
    
    final color = isIncome 
        ? Colors.green 
        : isTransfer 
            ? Colors.blue 
            : Colors.red;
    
    final icon = isIncome 
        ? Icons.arrow_downward 
        : isTransfer 
            ? Icons.swap_horiz 
            : Icons.arrow_upward;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            
            // Transaction Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ?? _getDefaultDescription(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        DateFormat('d MMM, HH:mm', 'ru').format(transaction.date),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      if (transaction.categoryId != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            transaction.categoryId!,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : isTransfer ? '' : '-'} ${_formatAmount(transaction.amount)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (transaction.currency != 'KGS')
                  Text(
                    transaction.currency,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDefaultDescription() {
    switch (transaction.type) {
      case TransactionType.income:
        return 'Доход';
      case TransactionType.expense:
        return 'Расход';
      case TransactionType.transfer:
        return 'Перевод';
    }
  }

  String _formatAmount(double amount) {
    final format = NumberFormat.currency(
      symbol: '₸',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return format.format(amount);
  }
}

/// Компактная версия карточки транзакции
class TransactionCardCompact extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback? onTap;

  const TransactionCardCompact({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(
        isIncome ? Icons.add_circle : Icons.remove_circle,
        color: color,
        size: 32,
      ),
      title: Text(
        transaction.description ?? 'Без описания',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        DateFormat('d MMM, HH:mm', 'ru').format(transaction.date),
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        '${isIncome ? '+' : '-'} ${_formatAmount(transaction.amount)}',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    final format = NumberFormat.currency(
      symbol: '₸',
      decimalDigits: amount % 1 == 0 ? 0 : 2,
    );
    return format.format(amount);
  }
}
