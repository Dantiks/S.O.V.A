import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/core/theme/glass_theme.dart';
import 'package:sova/presentation/providers/account_provider.dart';
import 'package:sova/presentation/screens/accounts/add_account_screen.dart';
import 'package:sova/presentation/screens/accounts/account_detail_screen.dart';
import 'package:intl/intl.dart';

class AccountsTab extends ConsumerWidget {
  const AccountsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accounts = ref.watch(accountProvider);
    final totalBalance = ref.read(accountProvider.notifier).getTotalBalance();

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
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Счета',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Управление финансами',
                            style: TextStyle(fontSize: 15, color: Colors.white60),
                          ),
                        ],
                      ),
                      WaterRippleButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddAccountScreen()),
                          );
                        },
                        padding: const EdgeInsets.all(14),
                        child: const Icon(Icons.add, color: Colors.white, size: 24),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(28),
                    gradient: GlassTheme.accentGradient,
                    boxShadow: GlassTheme.glowShadow,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Общий баланс', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${NumberFormat('#,###').format(totalBalance)} сом',
                                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_balance, color: Colors.white, size: 18),
                              const SizedBox(width: 12),
                              Text('Активных счетов: ${accounts.length}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              if (accounts.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassCard(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.white.withOpacity(0.4)),
                          ),
                          const SizedBox(height: 24),
                          const Text('Нет счетов', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Добавьте первый банковский счёт\nдля начала работы', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
                          const SizedBox(height: 28),
                          WaterRippleButton(
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAccountScreen()));
                            },
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, color: Colors.white),
                                SizedBox(width: 8),
                                Text('Добавить счёт', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final account = accounts[index];
                        final bankColors = {
                          'optima': const LinearGradient(colors: [Color(0xFFE91E63), Color(0xFFC2185B)]),
                          'demir': const LinearGradient(colors: [Color(0xFF2196F3), Color(0xFF1976D2)]),
                          'bakai': const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF388E3C)]),
                        };
                        final gradient = bankColors[account.bankId] ?? GlassTheme.accentGradient;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: WaterRippleButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => AccountDetailScreen(account: account)));
                            },
                            padding: EdgeInsets.zero,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: gradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                                    ),
                                  ),
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
                                      Text(account.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 8),
                                      Text('•••• ${account.accountNumber.substring(account.accountNumber.length - 4)}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Баланс', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                                              const SizedBox(height: 4),
                                              Text('${NumberFormat('#,###').format(account.balance)} ${account.currency}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                            child: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: accounts.length,
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
}
