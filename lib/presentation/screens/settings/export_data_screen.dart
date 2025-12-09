import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:finer/presentation/providers/transaction_provider.dart';
import 'package:finer/presentation/providers/account_provider.dart';
import 'package:finer/presentation/providers/goals_provider.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ExportDataScreen extends ConsumerStatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ConsumerState<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends ConsumerState<ExportDataScreen> {
  bool _isExporting = false;
  String _exportStatus = '';

  @override
  Widget build(BuildContext context) {
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
              // AppBar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Экспорт данных',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Info
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: const Color(0xFF7A3DF2),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Экспортируйте свои данные для резервного копирования или анализа',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Export options
                    const Text(
                      'Экспорт данных',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildExportCard(
                      icon: Icons.receipt_long,
                      title: 'Транзакции',
                      description: 'Экспорт всех транзакций в CSV',
                      color: const Color(0xFF2196F3),
                      onTap: () => _exportTransactions(),
                    ),

                    const SizedBox(height: 12),

                    _buildExportCard(
                      icon: Icons.account_balance_wallet,
                      title: 'Счета',
                      description: 'Экспорт информации о счетах',
                      color: const Color(0xFF4CAF50),
                      onTap: () => _exportAccounts(),
                    ),

                    const SizedBox(height: 12),

                    _buildExportCard(
                      icon: Icons.flag,
                      title: 'Цели',
                      description: 'Экспорт целей накоплений',
                      color: const Color(0xFFE91E63),
                      onTap: () => _exportGoals(),
                    ),

                    const SizedBox(height: 12),

                    _buildExportCard(
                      icon: Icons.folder_zip,
                      title: 'Полный экспорт',
                      description: 'Экспорт всех данных (все таблицы)',
                      color: const Color(0xFF7A3DF2),
                      onTap: () => _exportAll(),
                    ),

                    if (_isExporting) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF7A3DF2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _exportStatus,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Info box
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'О формате CSV',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• CSV файлы можно открыть в Excel, Google Sheets и других приложениях\n'
                            '• Данные экспортируются в текущем состоянии\n'
                            '• Файлы сохраняются локально и доступны для отправки',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: _isExporting ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.3),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportTransactions() async {
    setState(() {
      _isExporting = true;
      _exportStatus = 'Экспорт транзакций...';
    });

    try {
      final transactions = ref.read(transactionProvider);
      
      List<List<dynamic>> rows = [
        ['ID', 'Дата', 'Тип', 'Категория', 'Сумма', 'Описание', 'Счет'],
      ];

      for (var t in transactions) {
        rows.add([
          t.id,
          DateFormat('dd.MM.yyyy HH:mm').format(t.date),
          t.type == TransactionType.income ? 'Доход' : 'Расход',
          t.categoryId,
          t.amount,
          t.description,
          t.accountId,
        ]);
      }

      await _saveCsvAndShare(rows, 'transactions');
    } catch (e) {
      _showError('Ошибка экспорта: $e');
    } finally {
      setState(() {
        _isExporting = false;
        _exportStatus = '';
      });
    }
  }

  Future<void> _exportAccounts() async {
    setState(() {
      _isExporting = true;
      _exportStatus = 'Экспорт счетов...';
    });

    try {
      final accounts = ref.read(accountProvider);
      
      List<List<dynamic>> rows = [
        ['ID', 'Название', 'Банк', 'Номер счета', 'Баланс', 'Валюта', 'Тип'],
      ];

      for (var a in accounts) {
        rows.add([
          a.id,
          a.name,
          a.bankName,
          a.accountNumber,
          a.balance,
          a.currency,
          a.type,
        ]);
      }

      await _saveCsvAndShare(rows, 'accounts');
    } catch (e) {
      _showError('Ошибка экспорта: $e');
    } finally {
      setState(() {
        _isExporting = false;
        _exportStatus = '';
      });
    }
  }

  Future<void> _exportGoals() async {
    setState(() {
      _isExporting = true;
      _exportStatus = 'Экспорт целей...';
    });

    try {
      final goals = ref.read(goalsProvider);
      
      List<List<dynamic>> rows = [
        ['ID', 'Название', 'Целевая сумма', 'Текущая сумма', 'Дата начала', 'Целевая дата', 'Завершено'],
      ];

      for (var g in goals) {
        rows.add([
          g.id,
          g.name,
          g.targetAmount,
          g.currentAmount,
          DateFormat('dd.MM.yyyy').format(g.createdAt),
          DateFormat('dd.MM.yyyy').format(g.targetDate),
          g.isCompleted ? 'Да' : 'Нет',
        ]);
      }

      await _saveCsvAndShare(rows, 'goals');
    } catch (e) {
      _showError('Ошибка экспорта: $e');
    } finally {
      setState(() {
        _isExporting = false;
        _exportStatus = '';
      });
    }
  }

  Future<void> _exportAll() async {
    setState(() {
      _isExporting = true;
      _exportStatus = 'Экспорт всех данных...';
    });

    try {
      await _exportTransactions();
      await Future.delayed(const Duration(milliseconds: 500));
      await _exportAccounts();
      await Future.delayed(const Duration(milliseconds: 500));
      await _exportGoals();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Все данные успешно экспортированы'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showError('Ошибка экспорта: $e');
    } finally {
      setState(() {
        _isExporting = false;
        _exportStatus = '';
      });
    }
  }

  Future<void> _saveCsvAndShare(List<List<dynamic>> rows, String filename) async {
    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final path = '${directory.path}/SOVA_${filename}_$timestamp.csv';
    
    final file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles(
      [XFile(path)],
      text: 'Экспорт данных S.O.V.A: $filename',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$filename экспортированы успешно'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
