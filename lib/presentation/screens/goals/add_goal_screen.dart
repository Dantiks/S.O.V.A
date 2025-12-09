import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:finer/domain/entities/savings_goal_entity.dart';
import 'package:finer/presentation/providers/goals_provider.dart';

class AddGoalScreen extends ConsumerStatefulWidget {
  final SavingsGoalEntity? goal;

  const AddGoalScreen({super.key, this.goal});

  @override
  ConsumerState<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends ConsumerState<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _currentController = TextEditingController();
  
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));
  String _selectedIcon = '🎯';
  bool _isLoading = false;

  final List<String> _icons = [
    '🎯', '🏠', '🚗', '✈️', '💍', '🎓', '💰', '🎁', '📱', '⌚',
    '🏖️', '🎸', '📷', '💻', '🎮', '🏋️', '🎨', '📚', '🌟', '💎'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _nameController.text = widget.goal!.name;
      _targetController.text = widget.goal!.targetAmount.toString();
      _currentController.text = widget.goal!.currentAmount.toString();
      _targetDate = widget.goal!.targetDate;
      _selectedIcon = widget.goal!.icon;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _saveGoal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final goal = SavingsGoalEntity(
        id: widget.goal?.id ?? '',
        userId: 'demo_user',
        name: _nameController.text,
        targetAmount: double.parse(_targetController.text),
        currentAmount: double.parse(_currentController.text),
        targetDate: _targetDate,
        icon: _selectedIcon,
        createdAt: widget.goal?.createdAt ?? DateTime.now(),
      );

      if (widget.goal == null) {
        await ref.read(goalsProvider.notifier).addGoal(goal);
      } else {
        await ref.read(goalsProvider.notifier).updateGoal(goal);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Ошибка сохранения: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.withOpacity(0.8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: widget.goal == null ? 'Новая цель' : 'Редактировать цель',
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF0f0f1e),
            ],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Icon Selector
                const Text(
                  'Выберите иконку',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _icons.map((icon) {
                      final isSelected = _selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedIcon = icon),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: isSelected ? GlassTheme.accentGradient : null,
                            color: isSelected ? null : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF7A3DF2)
                                  : Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              icon,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),

                // Goal Name
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Название цели',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Например: Новый iPhone',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите название';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Target Amount
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Целевая сумма',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          suffix: Text(
                            'сом',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 20,
                            ),
                          ),
                          border: InputBorder.none,
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Current Amount
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Текущая сумма',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _currentController,
                        keyboardType: TextInputType.number,
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
                          suffix: Text(
                            'сом',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                          border: InputBorder.none,
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Target Date
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _targetDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFF7A3DF2),
                              surface: Color(0xFF1a1a2e),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (date != null) {
                      setState(() => _targetDate = date);
                    }
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: GlassTheme.accentGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_today, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Дата достижения',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_targetDate.day}.${_targetDate.month}.${_targetDate.year}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                WaterRippleButton(
                  onPressed: _isLoading ? () {} : _saveGoal,
                  height: 56,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.goal == null ? 'Создать цель' : 'Сохранить',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                if (widget.goal != null) ...[
                  const SizedBox(height: 16),
                  WaterRippleButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1a1a2e),
                          title: const Text(
                            'Удалить цель?',
                            style: TextStyle(color: Colors.white),
                          ),
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
                              child: const Text(
                                'Удалить',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await ref.read(goalsProvider.notifier)
                            .deleteGoal(widget.goal!.id);
                        if (mounted) {
                          Navigator.pop(context, true);
                        }
                      }
                    },
                    gradient: const LinearGradient(
                      colors: [Colors.red, Color(0xFFC62828)],
                    ),
                    height: 56,
                    child: const Text(
                      'Удалить цель',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
