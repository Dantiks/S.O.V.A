import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/domain/entities/family_account_entity.dart';

class FamilyBudgetScreen extends ConsumerWidget {
  const FamilyBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Семейный бюджет'),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () => _showInviteMemberDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFamilyCard(),
          const SizedBox(height: 24),
          const Text('Участники', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildMemberCard(
            FamilyMember(
              userId: '1',
              displayName: 'Вы',
              role: FamilyRole.admin,
              photoUrl: null,
            ),
          ),
          _buildMemberCard(
            FamilyMember(
              userId: '2',
              displayName: 'Супруг(а)',
              role: FamilyRole.member,
              photoUrl: null,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Общие счета', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildSharedAccountCard('Общий счет', 125000),
          _buildSharedAccountCard('Накопления', 50000),
        ],
      ),
    );
  }

  Widget _buildFamilyCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Общий баланс семьи', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            const Text('175,000 ₸', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Доходы', '+85,000 ₸', Colors.green),
                _buildStatItem('Расходы', '-45,000 ₸', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color)),
      ],
    );
  }

  Widget _buildMemberCard(FamilyMember member) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(member.displayName[0]),
        ),
        title: Text(member.displayName),
        subtitle: Text(_getRoleText(member.role)),
        trailing: member.role == FamilyRole.admin
            ? const Chip(label: Text('Администратор'))
            : PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'role', child: Text('Изменить роль')),
                  const PopupMenuItem(value: 'remove', child: Text('Удалить')),
                ],
              ),
      ),
    );
  }

  Widget _buildSharedAccountCard(String name, double balance) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.account_balance_wallet),
        ),
        title: Text(name),
        subtitle: Text('${balance.toStringAsFixed(0)} ₸'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _getRoleText(FamilyRole role) {
    switch (role) {
      case FamilyRole.admin: return 'Администратор';
      case FamilyRole.member: return 'Участник';
      case FamilyRole.viewer: return 'Наблюдатель';
    }
  }

  void _showInviteMemberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Пригласить участника'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'example@email.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Пригласить'),
          ),
        ],
      ),
    );
  }
}
