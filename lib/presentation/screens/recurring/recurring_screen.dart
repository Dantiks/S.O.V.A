import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/domain/entities/recurring_transaction_entity.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Регулярные платежи'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRecurringCard(
            RecurringTransactionEntity(
              id: '1',
              userId: 'user1',
              name: 'Netflix',
              amount: 500,
              category: 'entertainment',
              frequency: RecurringFrequency.monthly,
              startDate: DateTime(2024, 1, 1),
              accountId: 'acc1',
              merchantName: 'Netflix',
              nextDueDate: DateTime.now().add(const Duration(days: 5)),
            ),
          ),
          const SizedBox(height: 12),
          _buildRecurringCard(
            RecurringTransactionEntity(
              id: '2',
              userId: 'user1',
              name: 'Spotify',
              amount: 300,
              category: 'entertainment',
              frequency: RecurringFrequency.monthly,
              startDate: DateTime(2024, 1, 1),
              accountId: 'acc1',
              merchantName: 'Spotify',
              nextDueDate: DateTime.now().add(const Duration(days: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringCard(RecurringTransactionEntity recurring) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: const Icon(Icons.repeat, color: Colors.purple),
        ),
        title: Text(recurring.name),
        subtitle: Text('${recurring.amount} ₸ • ${_getFrequencyText(recurring.frequency)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              recurring.isDueToday ? 'Сегодня' : 'Через ${recurring.daysUntilDue} дн.',
              style: TextStyle(
                color: recurring.isDueToday ? Colors.red : Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(
              value: recurring.isActive,
              onChanged: (value) {},
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ),
    );
  }

  String _getFrequencyText(RecurringFrequency freq) {
    switch (freq) {
      case RecurringFrequency.daily: return 'Ежедневно';
      case RecurringFrequency.weekly: return 'Еженедельно';
      case RecurringFrequency.biweekly: return 'Раз в 2 недели';
      case RecurringFrequency.monthly: return 'Ежемесячно';
      case RecurringFrequency.quarterly: return 'Ежеквартально';
      case RecurringFrequency.yearly: return 'Ежегодно';
    }
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить регулярный платеж'),
        content: const Text('Функция в разработке'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
