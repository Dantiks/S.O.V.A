import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:finer/domain/entities/budget_entity.dart';
import 'package:finer/presentation/providers/budget_provider.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  final BudgetEntity? budget;

  const AddBudgetScreen({super.key, this.budget});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  
  String _selectedCategory = 'food';
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  double _warningThreshold = 0.8;
  bool _notifyOnExceed = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toStringAsFixed(0);
      _selectedCategory = widget.budget!.categoryId;
      _selectedPeriod = widget.budget!.period;
      _warningThreshold = widget.budget!.warningThreshold;
      _notifyOnExceed = widget.budget!.notifyOnExceed;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final budget = BudgetEntity(
        id: widget.budget?.id ?? '',
        userId: 'user123', // TODO: Get real user ID
        categoryId: _selectedCategory,
        amount: amount,
        currency: 'KGS',
        period: _selectedPeriod,
        startDate: DateTime.now(),
        warningThreshold: _warningThreshold,
        notifyOnExceed: _notifyOnExceed,
      );

      if (widget.budget != null) {
        await ref.read(budgetProvider.notifier).update(budget);
      } else {
        await ref.read(budgetProvider.notifier).add(budget);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.budget != null
                ? 'Бюджет обновлён'
                : 'Бюджет создан'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
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
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.budget != null ? 'Редактировать бюджет' : 'Новый бюджет',
          style: const TextStyle(
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
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Категория
                Text(
                  'Категория',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategorySelector(),
                
                const SizedBox(height: 24),

                // Сумма
                Text(
                  'Сумма бюджета',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GlassContainer(
                  padding: const EdgeInsets.all(4),
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      suffixText: '₸',
                      suffixStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите сумму';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Неверный формат';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Период
                Text(
                  'Период',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPeriodSelector(),

                const SizedBox(height: 24),

                // Настройки уведомлений
                Text(
                  'Уведомления',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.notifications_active, color: Colors.white, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Уведомлять о превышении',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Switch(
                            value: _notifyOnExceed,
                            onChanged: (value) {
                              setState(() => _notifyOnExceed = value);
                            },
                            activeColor: const Color(0xFF7A3DF2),
                          ),
                        ],
                      ),
                      if (_notifyOnExceed) ...[
                        const SizedBox(height: 16),
                        Divider(color: Colors.white.withOpacity(0.1)),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Порог предупреждения: ${(_warningThreshold * 100).toInt()}%',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Slider(
                              value: _warningThreshold,
                              min: 0.5,
                              max: 1.0,
                              divisions: 10,
                              activeColor: const Color(0xFF7A3DF2),
                              inactiveColor: Colors.white.withOpacity(0.2),
                              onChanged: (value) {
                                setState(() => _warningThreshold = value);
                              },
                            ),
                            Text(
                              'Вы получите уведомление при достижении этого процента',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Кнопка сохранения
                WaterRippleButton(
                  onPressed: _isLoading ? null : _saveBudget,
                  gradient: GlassTheme.accentGradient,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.budget != null ? 'Сохранить' : 'Создать бюджет',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 16),

                // Подсказка
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A3DF2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF7A3DF2),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Вы будете получать уведомления при достижении лимита бюджета',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'id': 'food', 'name': 'Продукты', 'icon': Icons.restaurant},
      {'id': 'transport', 'name': 'Транспорт', 'icon': Icons.directions_car},
      {'id': 'shopping', 'name': 'Покупки', 'icon': Icons.shopping_bag},
      {'id': 'entertainment', 'name': 'Развлечения', 'icon': Icons.movie},
      {'id': 'health', 'name': 'Здоровье', 'icon': Icons.local_hospital},
      {'id': 'utilities', 'name': 'Коммунальные', 'icon': Icons.home},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: categories.map((cat) {
        final isSelected = _selectedCategory == cat['id'];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedCategory = cat['id'] as String);
          },
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF7A3DF2), Color(0xFF5A2DB2)],
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat['icon'] as IconData,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  cat['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPeriodSelector() {
    return GlassContainer(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          _buildPeriodChip('День', BudgetPeriod.daily),
          const SizedBox(width: 6),
          _buildPeriodChip('Неделя', BudgetPeriod.weekly),
          const SizedBox(width: 6),
          _buildPeriodChip('Месяц', BudgetPeriod.monthly),
          const SizedBox(width: 6),
          _buildPeriodChip('Год', BudgetPeriod.yearly),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, BudgetPeriod period) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedPeriod = period);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? GlassTheme.accentGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
