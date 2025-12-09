import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:finer/presentation/providers/transaction_provider.dart';
import 'package:finer/presentation/providers/account_provider.dart';
import 'package:finer/presentation/providers/goals_provider.dart';
import 'package:intl/intl.dart';

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addMessage(
      'Привет! Я S.O.V.A - ваш умный финансовый помощник. Чем могу помочь?',
      isUser: false,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String text, {required bool isUser}) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _addMessage(message, isUser: true);
    _messageController.clear();

    setState(() => _isTyping = true);

    // Имитация задержки ответа
    await Future.delayed(const Duration(milliseconds: 800));

    final response = await _getAIResponse(message);
    
    setState(() => _isTyping = false);
    _addMessage(response, isUser: false);
  }

  Future<String> _getAIResponse(String message) async {
    final lowerMessage = message.toLowerCase();
    
    // Анализ баланса
    if (lowerMessage.contains('баланс') || lowerMessage.contains('сколько')) {
      final totalBalance = ref.read(accountProvider.notifier).getTotalBalance();
      return 'Ваш общий баланс составляет ${NumberFormat('#,###').format(totalBalance)} сом. ${_getBalanceAdvice(totalBalance)}';
    }
    
    // Анализ расходов
    if (lowerMessage.contains('расход') || lowerMessage.contains('трат')) {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final expense = ref.read(transactionProvider.notifier)
          .getExpenseForPeriod(startOfMonth, now);
      final income = ref.read(transactionProvider.notifier)
          .getIncomeForPeriod(startOfMonth, now);
      
      return 'За текущий месяц:\n\n💸 Расходы: ${NumberFormat('#,###').format(expense)} сом\n💰 Доходы: ${NumberFormat('#,###').format(income)} сом\n\n${_getSpendingAdvice(expense, income)}';
    }
    
    // Анализ целей
    if (lowerMessage.contains('цел') || lowerMessage.contains('накопл')) {
      final goals = ref.read(goalsProvider);
      final activeGoals = ref.read(goalsProvider.notifier).getActiveGoals();
      
      if (activeGoals.isEmpty) {
        return 'У вас пока нет активных целей накоплений. Рекомендую создать цель - это поможет планировать финансы!';
      }
      
      final closest = activeGoals.reduce((a, b) {
        final progressA = a.currentAmount / a.targetAmount;
        final progressB = b.currentAmount / b.targetAmount;
        return progressA > progressB ? a : b;
      });
      
      final progress = (closest.currentAmount / closest.targetAmount * 100).toStringAsFixed(0);
      return 'У вас ${activeGoals.length} активных целей.\n\nБлижайшая к завершению: "${closest.name}" (${closest.icon})\nПрогресс: $progress%\nОсталось накопить: ${NumberFormat('#,###').format(closest.targetAmount - closest.currentAmount)} сом';
    }
    
    // Советы по экономии
    if (lowerMessage.contains('совет') || lowerMessage.contains('как') || lowerMessage.contains('экономи')) {
      return _getSavingTips();
    }
    
    // Анализ категорий
    if (lowerMessage.contains('категор') || lowerMessage.contains('куда')) {
      final transactions = ref.read(transactionProvider);
      if (transactions.isEmpty) {
        return 'У вас пока нет транзакций для анализа. Добавьте несколько транзакций, и я смогу показать детальную статистику!';
      }
      
      final Map<String, double> categoryTotals = {};
      for (var t in transactions) {
        if (t.type == TransactionType.expense) {
          categoryTotals[t.categoryId] = (categoryTotals[t.categoryId] ?? 0) + t.amount;
        }
      }
      
      final sorted = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final top = sorted.take(3).map((e) => 
        '• ${e.key}: ${NumberFormat('#,###').format(e.value)} сом'
      ).join('\n');
      
      return 'Топ-3 категории расходов:\n\n$top\n\n${_getCategoryAdvice(sorted.first.key)}';
    }
    
    // Прогноз
    if (lowerMessage.contains('прогноз') || lowerMessage.contains('будущ')) {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final expense = ref.read(transactionProvider.notifier)
          .getExpenseForPeriod(startOfMonth, now);
      
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final daysPassed = now.day;
      final avgPerDay = expense / daysPassed;
      final forecast = avgPerDay * daysInMonth;
      
      return 'Прогноз на конец месяца:\n\n📊 Средние расходы в день: ${NumberFormat('#,###').format(avgPerDay)} сом\n📈 Прогноз расходов: ${NumberFormat('#,###').format(forecast)} сом\n\n${_getForecastAdvice(forecast)}';
    }
    
    // Общая помощь
    return 'Я могу помочь вам с:\n\n💰 Анализом баланса\n📊 Статистикой расходов\n🎯 Целями накоплений\n📈 Прогнозами\n💡 Советами по экономии\n\nПросто спросите меня!';
  }

  String _getBalanceAdvice(double balance) {
    if (balance < 0) {
      return '⚠️ Внимание! У вас отрицательный баланс. Рекомендую срочно пересмотреть расходы.';
    } else if (balance < 10000) {
      return '💡 Совет: Создайте финансовую подушку безопасности минимум 50,000 сом.';
    } else if (balance < 50000) {
      return '👍 Неплохо! Продолжайте накапливать резервный фонд.';
    } else {
      return '🎉 Отличный баланс! Рассмотрите возможность инвестирования части средств.';
    }
  }

  String _getSpendingAdvice(double expense, double income) {
    final ratio = expense / income;
    if (ratio > 0.9) {
      return '⚠️ Вы тратите ${(ratio * 100).toStringAsFixed(0)}% от доходов! Рекомендую сократить расходы.';
    } else if (ratio > 0.7) {
      return '💡 Вы тратите ${(ratio * 100).toStringAsFixed(0)}% от доходов. Старайтесь откладывать минимум 20%.';
    } else {
      return '✅ Отличное управление финансами! Вы тратите только ${(ratio * 100).toStringAsFixed(0)}% от доходов.';
    }
  }

  String _getSavingTips() {
    final tips = [
      '💡 Правило 50/30/20: 50% на необходимое, 30% на желаемое, 20% на накопления',
      '🎯 Автоматизируйте накопления - откладывайте деньги сразу после получения дохода',
      '📊 Отслеживайте все расходы - это поможет найти "утечки" в бюджете',
      '🛒 Составляйте список покупок и придерживайтесь его',
      '💳 Используйте кэшбэк и бонусные программы банков',
    ];
    return tips[DateTime.now().second % tips.length];
  }

  String _getCategoryAdvice(String category) {
    final advices = {
      'Продукты': '🛒 Совет: Планируйте меню на неделю и покупайте по списку',
      'Транспорт': '🚗 Совет: Рассмотрите использование общественного транспорта',
      'Развлечения': '🎬 Совет: Ищите бесплатные или недорогие альтернативы',
      'Здоровье': '💊 Совет: Профилактика дешевле лечения - следите за здоровьем',
    };
    return advices[category] ?? '💡 Совет: Анализируйте необходимость каждой покупки';
  }

  String _getForecastAdvice(double forecast) {
    if (forecast > 100000) {
      return '⚠️ Прогноз показывает высокие расходы. Рекомендую пересмотреть бюджет.';
    } else if (forecast > 50000) {
      return '💡 Умеренные расходы. Следите за крупными тратами.';
    } else {
      return '✅ Прогноз в пределах нормы. Продолжайте в том же духе!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: GlassTheme.accentGradient,
                        shape: BoxShape.circle,
                        boxShadow: GlassTheme.glowShadow,
                      ),
                      child: const Icon(Icons.smart_toy, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'S.O.V.A AI',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Финансовый помощник',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    return _buildMessage(message);
                  },
                ),
              ),

              // Typing Indicator
              if (_isTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTypingDot(0),
                            const SizedBox(width: 4),
                            _buildTypingDot(1),
                            const SizedBox(width: 4),
                            _buildTypingDot(2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Input
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: _messageController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Спросите меня о финансах...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    WaterRippleButton(
                      onPressed: _sendMessage,
                      padding: const EdgeInsets.all(16),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                gradient: GlassTheme.accentGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
          Flexible(
            child: GlassContainer(
              padding: const EdgeInsets.all(16),
              gradient: message.isUser ? GlassTheme.accentGradient : null,
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animValue = ((value + delay) % 1.0);
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3 + (animValue * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () => setState(() {}),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}
