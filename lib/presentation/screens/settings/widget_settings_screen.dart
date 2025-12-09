import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:home_widget/home_widget.dart' as hw;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finer/presentation/providers/account_provider.dart';
import 'package:finer/presentation/providers/transaction_provider.dart';

// Провайдер для выбранного типа виджета
final widgetTypeProvider = StateProvider<WidgetType>((ref) => WidgetType.balance);

enum WidgetType {
  balance,
  expenses,
  income,
  chart,
}

class WidgetSettingsScreen extends ConsumerStatefulWidget {
  const WidgetSettingsScreen({super.key});

  @override
  ConsumerState<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends ConsumerState<WidgetSettingsScreen> {
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    // Загрузить текущие настройки виджета
    final type = await hw.HomeWidget.getWidgetData<String>('widget_type');
    if (type != null && mounted) {
      ref.read(widgetTypeProvider.notifier).state = 
          WidgetType.values.firstWhere(
            (e) => e.name == type,
            orElse: () => WidgetType.balance,
          );
    }
  }

  Future<void> _updateWidget() async {
    setState(() => _isUpdating = true);

    try {
      final selectedType = ref.read(widgetTypeProvider);
      final accounts = ref.read(accountProvider);
      
      // Подсчет баланса
      final totalBalance = accounts.fold<double>(
        0,
        (sum, account) => sum + account.balance,
      );

      // Подсчет доходов и расходов
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final transactions = ref.read(transactionProvider.notifier)
          .getByPeriod(startOfMonth, now);
      
      final income = transactions
          .where((t) => t.type == TransactionType.income)
          .fold<double>(0, (sum, t) => sum + t.amount);
      
      final expenses = transactions
          .where((t) => t.type == TransactionType.expense)
          .fold<double>(0, (sum, t) => sum + t.amount);

      // Сохранить данные для виджета
      await hw.HomeWidget.saveWidgetData('widget_type', selectedType.name);
      await hw.HomeWidget.saveWidgetData('total_balance', totalBalance);
      await hw.HomeWidget.saveWidgetData('monthly_income', income);
      await hw.HomeWidget.saveWidgetData('monthly_expenses', expenses);
      await hw.HomeWidget.saveWidgetData('app_name', 'FINER');
      
      // Обновить виджет
      await hw.HomeWidget.updateWidget(
        name: 'FinerWidgetProvider',
        androidName: 'FinerWidgetProvider',
        iOSName: 'FinerWidget',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Виджет обновлён'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(widgetTypeProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Виджет на рабочем столе',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Описание
              Text(
                'Добавьте виджет FINER на главный экран для быстрого доступа к финансовой информации',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 15,
                  height: 1.5,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 32),

              // Выбор типа виджета
              Text(
                'Тип виджета',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 16),

              // Варианты виджетов
              _buildWidgetTypeCard(
                type: WidgetType.balance,
                icon: Icons.account_balance_wallet,
                title: 'Общий баланс',
                subtitle: 'Показывает суммарный баланс всех счетов',
                isSelected: selectedType == WidgetType.balance,
                delay: 150,
              ),
              
              const SizedBox(height: 12),
              
              _buildWidgetTypeCard(
                type: WidgetType.expenses,
                icon: Icons.trending_down,
                title: 'Расходы за месяц',
                subtitle: 'Отображает расходы текущего месяца',
                isSelected: selectedType == WidgetType.expenses,
                delay: 200,
              ),
              
              const SizedBox(height: 12),
              
              _buildWidgetTypeCard(
                type: WidgetType.income,
                icon: Icons.trending_up,
                title: 'Доходы за месяц',
                subtitle: 'Отображает доходы текущего месяца',
                isSelected: selectedType == WidgetType.income,
                delay: 250,
              ),
              
              const SizedBox(height: 12),
              
              _buildWidgetTypeCard(
                type: WidgetType.chart,
                icon: Icons.pie_chart,
                title: 'Финансовая сводка',
                subtitle: 'Баланс, доходы и расходы',
                isSelected: selectedType == WidgetType.chart,
                delay: 300,
              ),

              const SizedBox(height: 32),

              // Инструкция
              GlassContainer(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7A3DF2).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF7A3DF2),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Как добавить виджет',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionStep('1', 'Долгое нажатие на главный экран'),
                    const SizedBox(height: 8),
                    _buildInstructionStep('2', 'Выберите "Виджеты"'),
                    const SizedBox(height: 8),
                    _buildInstructionStep('3', 'Найдите виджет FINER'),
                    const SizedBox(height: 8),
                    _buildInstructionStep('4', 'Перетащите на главный экран'),
                  ],
                ),
              ).animate(delay: 350.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 24),

              // Кнопка обновления
              WaterRippleButton(
                onPressed: _isUpdating ? null : _updateWidget,
                gradient: GlassTheme.accentGradient,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _isUpdating
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.refresh, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Обновить виджет',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 16),

              // Подсказка о частоте обновления
              Text(
                'Виджет автоматически обновляется каждый час. Используйте кнопку для принудительного обновления.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetTypeCard({
    required WidgetType type,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required int delay,
  }) {
    return GestureDetector(
      onTap: () {
        ref.read(widgetTypeProvider.notifier).state = type;
      },
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        gradient: isSelected
            ? const LinearGradient(
                colors: [Color(0xFF7A3DF2), Color(0xFF5A2DB2)],
              )
            : null,
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF7A3DF2).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFF7A3DF2).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideX(begin: -0.2, end: 0);
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF7A3DF2).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF7A3DF2),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
