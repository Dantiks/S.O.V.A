import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:finer/presentation/providers/account_provider.dart';
import 'package:finer/presentation/providers/transaction_provider.dart';
import 'package:finer/presentation/providers/recurring_provider.dart';
import 'package:finer/presentation/providers/notification_provider.dart';
import 'package:finer/domain/entities/transaction_entity.dart';
import 'package:finer/presentation/screens/notifications/notifications_screen.dart';
import 'package:finer/presentation/screens/transactions/all_transactions_screen.dart';
import 'package:finer/presentation/screens/transactions/add_transaction_screen.dart';
import 'package:finer/core/services/tutorial_service.dart';
import 'package:finer/presentation/widgets/ai_helper_button.dart';
import 'package:finer/presentation/providers/budget_provider.dart';
import 'package:finer/presentation/screens/budgets/budgets_screen.dart';
import 'package:finer/presentation/screens/home/tabs/chat_tab.dart';

class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
  final _currencyFormat = NumberFormat.currency(symbol: '₸', decimalDigits: 2);
  bool _showHelperPulse = false;
  
  @override
  void initState() {
    super.initState();
    _checkAndShowTutorial();
  }
  
  Future<void> _checkAndShowTutorial() async {
    final completed = await TutorialService.isTutorialCompleted();
    if (!completed && mounted) {
      // Показать туториал после небольшой задержки
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          TutorialService.showTutorial(
            context,
            onComplete: () {
              setState(() => _showHelperPulse = true);
              // Остановить пульсацию через 5 секунд
              Future.delayed(const Duration(seconds: 5), () {
                if (mounted) {
                  setState(() => _showHelperPulse = false);
                }
              });
            },
          );
        }
      });
    }
  }
  
  void _navigateToChat() {
    // Переключиться на вкладку чата
    // Это будет работать через контроллер главного экрана
    Navigator.of(context).popUntil((route) => route.isFirst);
    // TODO: Переключить на вкладку чата программно
  }
  
  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountProvider);
    final transactions = ref.watch(transactionProvider);
    final recurring = ref.watch(recurringProvider);
    
    final totalBalance = accounts.fold(0.0, (sum, acc) => sum + acc.balance);
    
    // Расчет доходов и расходов за текущий месяц
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    final monthTransactions = transactions.where((t) {
      return t.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             t.date.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
    
    final monthIncome = monthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final monthExpense = monthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final recentTransactions = transactions.take(5).toList();
    final dueRecurring = recurring.where((r) => r.isActive && r.daysUntilDue <= 7).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(accountProvider.notifier).loadAccounts();
            await ref.read(transactionProvider.notifier).loadTransactions();
            await ref.read(recurringProvider.notifier).loadRecurring();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.black,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Финансы под контролем �',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, d MMMM', 'ru').format(now),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // AI Помощник
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AIHelperMiniButton(
                      onTap: _navigateToChat,
                    ),
                  ),
                  // Уведомления
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          );
                        },
                      ),
                      Consumer(
                        builder: (context, ref, _) {
                          final unreadCount = ref.watch(unreadNotificationsCountProvider);
                          if (unreadCount == 0) return const SizedBox.shrink();
                          return Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                unreadCount > 9 ? '9+' : unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Карточка общего баланса
                    _buildBalanceCard(context, totalBalance, monthIncome, monthExpense)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                    // Бюджеты (если есть)
                    Consumer(
                      builder: (context, ref, child) {
                        final budgets = ref.watch(budgetProvider);
                        final activeBudgets = budgets.where((b) => b.isActive).toList();
                        
                        if (activeBudgets.isEmpty) return const SizedBox.shrink();
                        
                        return Column(
                          children: [
                            _buildSectionHeader(context, 'Бюджеты', Icons.account_balance_wallet),
                            const SizedBox(height: 12),
                            _buildBudgetsSummary(context, activeBudgets)
                                .animate(delay: 100.ms)
                                .fadeIn(duration: 600.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                    
                    // Быстрые действия
                    _buildSectionHeader(context, 'Быстрые действия', Icons.flash_on),
                    const SizedBox(height: 12),
                    _buildQuickActions(context)
                        .animate(delay: 100.ms)
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: 0.2, end: 0),
                    
                    const SizedBox(height: 24),
                    
                    // Предстоящие регулярные платежи
                    if (dueRecurring.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Предстоящие платежи', Icons.event),
                      const SizedBox(height: 12),
                      ...dueRecurring.map((r) => _buildRecurringCard(context, r)),
                      const SizedBox(height: 24),
                    ],
                    
                    // Последние транзакции
                    _buildSectionHeader(context, 'Последние транзакции', Icons.history),
                    const SizedBox(height: 12),
                    
                    if (recentTransactions.isEmpty)
                      _buildEmptyState(context, 'Нет транзакций', 'Добавьте первую транзакцию')
                    else
                      ...recentTransactions.map((t) => _buildTransactionCard(context, t)),
                    
                    const SizedBox(height: 16),
                    
                    // Кнопка "Показать все"
                    if (transactions.length > 5)
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AllTransactionsScreen()),
                          );
                        },
                        child: const Text('Показать все транзакции'),
                      ),
                    
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddTransactionDialog(context);
        },
        backgroundColor: const Color(0xFF7A3DF2),
        icon: const Icon(Icons.add),
        label: const Text('Транзакция'),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, double balance, double income, double expense) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7A3DF2), Color(0xFF5A2DB2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A3DF2).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Общий баланс',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.visibility, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text('KGS', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currencyFormat.format(balance),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBalanceInfo(
                  context,
                  'Доходы',
                  income,
                  Icons.arrow_downward,
                  Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBalanceInfo(
                  context,
                  'Расходы',
                  expense,
                  Icons.arrow_upward,
                  Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceInfo(BuildContext context, String label, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _currencyFormat.format(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            context,
            'Добавить\nдоход',
            Icons.add_circle_outline,
            Colors.green,
            () => _showAddTransaction(TransactionType.income),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context,
            'Добавить\nрасход',
            Icons.remove_circle_outline,
            Colors.red,
            () => _showAddTransaction(TransactionType.expense),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            context,
            'Перевод\nмежду счетами',
            Icons.swap_horiz,
            Colors.blue,
            () => _showAddTransaction(TransactionType.transfer),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7A3DF2), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringCard(BuildContext context, dynamic recurring) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_repeat, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recurring.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Через ${recurring.daysUntilDue} ${_getDaysWord(recurring.daysUntilDue)}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _currencyFormat.format(recurring.amount),
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, TransactionEntity transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Без описания',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('d MMM, HH:mm', 'ru').format(transaction.date),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ${_currencyFormat.format(transaction.amount)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetsSummary(BuildContext context, List<dynamic> budgets) {
    final notifier = ref.read(budgetProvider.notifier);
    
    // Показываем только первые 2 бюджета
    final displayBudgets = budgets.take(2).toList();
    
    return Column(
      children: [
        ...displayBudgets.map((budget) {
          final progress = notifier.getProgress(budget);
          final percentage = notifier.getPercentage(budget);
          final remaining = notifier.getRemaining(budget);
          final isWarning = notifier.isWarning(budget);
          final isExceeded = notifier.isExceeded(budget);
          
          Color progressColor;
          if (isExceeded) {
            progressColor = Colors.red;
          } else if (isWarning) {
            progressColor = Colors.orange;
          } else {
            progressColor = const Color(0xFF7A3DF2);
          }
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.restaurant, // TODO: динамическая иконка
                      color: progressColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Продукты', // TODO: динамическое название
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: progressColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Осталось: ${remaining.toStringAsFixed(0)} ₸',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    if (isExceeded)
                      Text(
                        '⚠️ Превышен',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else if (isWarning)
                      Text(
                        '⚠️ Близко к лимиту',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
        
        // Кнопка "Все бюджеты"
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BudgetsScreen()),
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('Все бюджеты'),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  String _getDaysWord(int days) {
    if (days == 0) return 'сегодня';
    if (days == 1) return 'день';
    if (days >= 2 && days <= 4) return 'дня';
    return 'дней';
  }

  void _showAddTransaction(TransactionType type) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddTransactionScreen(transaction: null),
      ),
    );
    
    // Если транзакция была успешно добавлена
    if (result == true && mounted) {
      // Показать уведомление об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                type == TransactionType.income
                    ? 'Доход успешно добавлен'
                    : type == TransactionType.expense
                    ? 'Расход успешно добавлен'
                    : 'Перевод выполнен',
              ),
            ],
          ),
          backgroundColor: Colors.green.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Обновить данные
      ref.refresh(transactionProvider);
      ref.refresh(accountProvider);
    }
  }
  
  void _showAddTransactionDialog(BuildContext context, {TransactionType? type}) {
    _showAddTransaction(type ?? TransactionType.expense);
  }
}
