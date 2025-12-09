import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:finer/core/config/env_config.dart';

class OpenAIService {
  late final OpenAI _openAI;
  final List<Map<String, String>> _conversationHistory = [];

  OpenAIService({String? apiKey}) {
    final key = apiKey ?? EnvConfig.openAIApiKey;
    
    if (key.isEmpty) {
      throw Exception('OpenAI API key не настроен! Добавьте OPENAI_API_KEY в .env файл');
    }
    
    _openAI = OpenAI.instance.build(
      token: key,
      baseOption: HttpSetup(
        receiveTimeout: const Duration(seconds: 30),
        connectTimeout: const Duration(seconds: 30),
      ),
      enableLog: false, // Отключаем логи в продакшене
    );
  }

  Future<String> sendMessage(String message, {String? userId}) async {
    try {
      // Добавляем сообщение пользователя в историю
      _conversationHistory.add({
        'role': 'user',
        'content': message,
      });

      // Создаем системный промпт для финансового ассистента
      final systemPrompt = '''
Ты - SOVA, умный финансовый AI-ассистент для пользователей из Кыргызстана.

Твои задачи:
- Помогать управлять личными финансами
- Анализировать доходы и расходы
- Давать советы по экономии и инвестициям
- Отвечать на вопросы о банках Кыргызстана (Optima Bank, KICB, DemirBank, DosCredoBank, Halyk Bank, Bai Tushum, Keremet Bank, MBank, Kapital Bank, eLCARD)
- Помогать планировать бюджет
- Категоризировать транзакции

Отвечай кратко, по делу, на русском языке. Используй эмодзи для наглядности.
''';

      // Формируем сообщения для API
      final messages = [
        Messages(role: Role.system, content: systemPrompt),
        ..._conversationHistory.map((msg) => Messages(
              role: msg['role'] == 'user' ? Role.user : Role.assistant,
              content: msg['content']!,
            )),
      ];

      // Отправляем запрос
      final request = ChatCompleteText(
        messages: messages,
        maxToken: 500,
        model: Gpt4ChatModel(),
        temperature: 0.7,
      );

      final response = await _openAI.onChatCompletion(request: request);

      if (response != null && response.choices.isNotEmpty) {
        final assistantMessage = response.choices.first.message?.content ?? 'Извините, не смог обработать запрос.';
        
        // Добавляем ответ в историю
        _conversationHistory.add({
          'role': 'assistant',
          'content': assistantMessage,
        });

        return assistantMessage;
      }

      return 'Извините, не получил ответ от сервера.';
    } catch (e) {
      print('OpenAI Error: $e');
      return 'Ошибка: ${e.toString()}';
    }
  }

  Future<String> analyzeFinances({
    required double totalIncome,
    required double totalExpenses,
    required Map<String, double> categoryExpenses,
  }) async {
    final prompt = '''
Проанализируй мои финансы за месяц:

💰 Доходы: $totalIncome сом
💸 Расходы: $totalExpenses сом
📊 Баланс: ${totalIncome - totalExpenses} сом

Расходы по категориям:
${categoryExpenses.entries.map((e) => '${e.key}: ${e.value} сом').join('\n')}

Дай краткий анализ и 3 совета по оптимизации расходов.
''';

    return sendMessage(prompt);
  }

  Future<String> categorizeTransaction({
    required String description,
    required double amount,
    String? merchant,
  }) async {
    final prompt = '''
Определи категорию для транзакции:
Описание: $description
Сумма: $amount сом
${merchant != null ? 'Торговая точка: $merchant' : ''}

Выбери одну категорию из списка:
- Продукты
- Транспорт
- Развлечения
- Здоровье
- Образование
- Коммунальные услуги
- Одежда
- Рестораны
- Другое

Ответь только названием категории.
''';

    return sendMessage(prompt);
  }

  Future<String> getBudgetAdvice({
    required double monthlyIncome,
    required List<String> financialGoals,
  }) async {
    final prompt = '''
Мой месячный доход: $monthlyIncome сом

Мои финансовые цели:
${financialGoals.map((goal) => '- $goal').join('\n')}

Помоги составить бюджет и дай рекомендации по достижению целей.
''';

    return sendMessage(prompt);
  }

  void clearHistory() {
    _conversationHistory.clear();
  }

  List<Map<String, String>> getHistory() {
    return List.unmodifiable(_conversationHistory);
  }
}
