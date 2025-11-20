import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/domain/entities/savings_goal_entity.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Цели накоплений'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement create goal screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Функция в разработке')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGoalCard(
            context,
            SavingsGoalEntity(
              id: '1',
              userId: 'user1',
              name: 'Отпуск в Турции',
              description: 'Семейный отдых летом',
              targetAmount: 150000,
              currentAmount: 45000,
              startDate: DateTime(2024, 1, 1),
              targetDate: DateTime(2024, 7, 1),
              category: 'travel',
              iconName: 'flight',
              colorHex: '#3B82F6',
            ),
          ),
          const SizedBox(height: 16),
          _buildGoalCard(
            context,
            SavingsGoalEntity(
              id: '2',
              userId: 'user1',
              name: 'Новый MacBook',
              description: 'MacBook Pro M3',
              targetAmount: 200000,
              currentAmount: 80000,
              startDate: DateTime(2024, 1, 1),
              targetDate: DateTime(2024, 12, 1),
              category: 'electronics',
              iconName: 'laptop',
              colorHex: '#10B981',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingsGoalEntity goal) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(int.parse(goal.colorHex.replaceAll('#', '0xFF'))),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flight, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(goal.description, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: goal.progress, minHeight: 8),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(goal.progress * 100).toStringAsFixed(1)}%'),
                Text('${goal.currentAmount.toStringAsFixed(0)} / ${goal.targetAmount.toStringAsFixed(0)} ₸'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${goal.daysRemaining} дней осталось', style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                Text(
                  'Нужно: ${goal.requiredMonthlyContribution.toStringAsFixed(0)} ₸/мес',
                  style: TextStyle(color: goal.isOnTrack ? Colors.green : Colors.orange, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
