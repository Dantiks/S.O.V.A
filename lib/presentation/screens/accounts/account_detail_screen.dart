import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:finer/domain/entities/account_entity.dart';
import 'package:finer/presentation/providers/account_provider.dart';
import 'package:finer/presentation/providers/transaction_provider.dart';
import 'package:finer/presentation/screens/accounts/add_account_screen.dart';
import 'package:intl/intl.dart';

class AccountDetailScreen extends ConsumerStatefulWidget {
  final AccountEntity account;
  const AccountDetailScreen({super.key, required this.account});

  @override
  ConsumerState<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  void _showActionDialog(String action) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(action, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Сумма',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7A3DF2))),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                double newBalance = widget.account.balance;
                if (action == 'Пополнить') newBalance += amount;
                else if (action == 'Снять') newBalance -= amount;
                
                await ref.read(accountProvider.notifier).updateBalance(widget.account.id, newBalance);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$action: ${NumberFormat('#,###').format(amount)} сом'), backgroundColor: Colors.green),
                  );
                }
              }
            },
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider).firstWhere((a) => a.id == widget.account.id, orElse: () => widget.account);
    final accountTransactions = ref.watch(transactionProvider).where((t) => t.accountId == account.id).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)])),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                actions: [IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddAccountScreen(account: account))))],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(28),
                    gradient: GlassTheme.accentGradient,
                    boxShadow: GlassTheme.glowShadow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                              child: Text(account.bankId.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                            Icon(Icons.credit_card, color: Colors.white.withOpacity(0.7), size: 32),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(account.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Text(account.accountNumber, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                        const SizedBox(height: 24),
                        Text('Текущий баланс', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                        const SizedBox(height: 8),
                        Text('${NumberFormat('#,###').format(account.balance)} ${account.currency}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: _buildActionButton('Пополнить', Icons.add_circle_outline, const Color(0xFF4CAF50), () => _showActionDialog('Пополнить'))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildActionButton('Снять', Icons.remove_circle_outline, const Color(0xFFE53935), () => _showActionDialog('Снять'))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildActionButton('Отправить', Icons.send, const Color(0xFF2196F3), () => _showActionDialog('Отправить'))),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('История транзакций', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)))),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (accountTransactions.isEmpty)
                SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: GlassCard(padding: const EdgeInsets.all(40), child: Column(children: [Icon(Icons.receipt_long, size: 64, color: Colors.white.withOpacity(0.3)), const SizedBox(height: 16), Text('Нет транзакций', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 16))]))))
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final t = accountTransactions[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(gradient: t.type == TransactionType.income ? const LinearGradient(colors: [Colors.green, Color(0xFF2E7D32)]) : const LinearGradient(colors: [Colors.red, Color(0xFFC62828)]), borderRadius: BorderRadius.circular(12)),
                                  child: Icon(t.type == TransactionType.income ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white),
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.categoryId, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)), const SizedBox(height: 4), Text(DateFormat('dd MMM, HH:mm').format(t.date), style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13))])),
                                Text('${t.type == TransactionType.income ? '+' : '-'}${NumberFormat('#,###').format(t.amount)}', style: TextStyle(color: t.type == TransactionType.income ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: accountTransactions.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return WaterRippleButton(
      onPressed: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)), const SizedBox(height: 8), Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))]),
    );
  }
}
