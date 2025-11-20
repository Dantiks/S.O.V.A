import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/core/theme/glass_theme.dart';
import 'package:sova/domain/entities/bank_account_entity.dart';
import 'package:sova/presentation/providers/account_provider.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  final BankAccountEntity? account;

  const AddAccountScreen({super.key, this.account});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _accountNumberController = TextEditingController();
  
  String? _selectedBank;
  String _selectedCurrency = 'KGS';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _banks = [
    {'id': 'optima', 'name': 'Оптима Банк', 'color': Color(0xFFE91E63)},
    {'id': 'demir', 'name': 'Демир Банк', 'color': Color(0xFF2196F3)},
    {'id': 'rsk', 'name': 'РСК Банк', 'color': Color(0xFF4CAF50)},
    {'id': 'bakai', 'name': 'Бакай Банк', 'color': Color(0xFFFF9800)},
    {'id': 'kicb', 'name': 'KICB', 'color': Color(0xFF9C27B0)},
    {'id': 'dos', 'name': 'Dos-Kredobанк', 'color': Color(0xFFF44336)},
    {'id': 'kompanion', 'name': 'Компаньон', 'color': Color(0xFF00BCD4)},
    {'id': 'bai_tushum', 'name': 'Бай-Түшүм', 'color': Color(0xFF795548)},
    {'id': 'kyrgyz', 'name': 'Кыргызкоммерцбанк', 'color': Color(0xFF607D8B)},
    {'id': 'halyk', 'name': 'Halyk Bank', 'color': Color(0xFF3F51B5)},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.accountName;
      _balanceController.text = widget.account!.balance.toString();
      _accountNumberController.text = widget.account!.accountNumber;
      _selectedBank = widget.account!.bankId;
      _selectedCurrency = widget.account!.currency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedBank == null) {
      _showError('Выберите банк');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bank = _banks.firstWhere((b) => b['id'] == _selectedBank);
      final account = BankAccountEntity(
        id: widget.account?.id ?? '',
        userId: 'demo_user',
        bankId: _selectedBank!,
        bankName: bank['name'],
        accountName: _nameController.text,
        accountNumber: _accountNumberController.text,
        balance: double.parse(_balanceController.text),
        currency: _selectedCurrency,
        isActive: true,
        createdAt: widget.account?.createdAt ?? DateTime.now(),
      );

      if (widget.account == null) {
        await ref.read(accountProvider.notifier).addAccount(account);
      } else {
        await ref.read(accountProvider.notifier).updateAccount(account);
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
        title: widget.account == null ? 'Новый счет' : 'Редактировать счет',
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
                // Выбор банка
                const Text(
                  'Выберите банк',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: _banks.length,
                  itemBuilder: (context, index) {
                    final bank = _banks[index];
                    final isSelected = _selectedBank == bank['id'];
                    return WaterRippleButton(
                      onPressed: () => setState(() => _selectedBank = bank['id']),
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [bank['color'], bank['color'].withOpacity(0.7)],
                            )
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: bank['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              bank['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Название счета
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Название счета',
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
                          hintText: 'Моя карта',
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

                // Номер счета
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Номер счета',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _accountNumberController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: '1234 5678 9012 3456',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите номер счета';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Баланс
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Начальный баланс',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _balanceController,
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
                            _selectedCurrency,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 20,
                            ),
                          ),
                          border: InputBorder.none,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите баланс';
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

                // Валюта
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.currency_exchange, color: Colors.white),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Валюта',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DropdownButton<String>(
                              value: _selectedCurrency,
                              dropdownColor: const Color(0xFF1a1a2e),
                              underline: const SizedBox(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              items: ['KGS', 'USD', 'EUR', 'RUB']
                                  .map((currency) => DropdownMenuItem(
                                        value: currency,
                                        child: Text(currency),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedCurrency = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Кнопка сохранения
                WaterRippleButton(
                  onPressed: _isLoading ? () {} : _saveAccount,
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
                          widget.account == null ? 'Добавить счет' : 'Сохранить',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                if (widget.account != null) ...[
                  const SizedBox(height: 16),
                  WaterRippleButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xFF1a1a2e),
                          title: const Text(
                            'Удалить счет?',
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
                        await ref.read(accountProvider.notifier)
                            .deleteAccount(widget.account!.id);
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
                      'Удалить счет',
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
