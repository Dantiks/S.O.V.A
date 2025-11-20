import 'package:flutter/foundation.dart';

/// Конфигурация приложения с API ключами
/// В production эти значения должны загружаться из .env файла
class EnvConfig {
  // OpenAI API Key
  static String get openAIApiKey {
    // В production используйте flutter_dotenv или другой пакет для загрузки .env
    const key = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    if (key.isEmpty && kDebugMode) {
      debugPrint('⚠️ WARNING: OPENAI_API_KEY не установлен!');
    }
    return key;
  }

  // Currency API Key
  static String get currencyApiKey {
    const key = String.fromEnvironment('CURRENCY_API_KEY', defaultValue: '');
    if (key.isEmpty && kDebugMode) {
      debugPrint('⚠️ WARNING: CURRENCY_API_KEY не установлен!');
    }
    return key;
  }

  // Firebase Config
  static String get firebaseApiKey {
    const key = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
    return key;
  }

  static String get firebaseProjectId {
    const key = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');
    return key;
  }

  // Проверить все ключи
  static bool get areKeysConfigured {
    return openAIApiKey.isNotEmpty && currencyApiKey.isNotEmpty;
  }

  // Вывести статус конфигурации
  static void printStatus() {
    if (kDebugMode) {
      debugPrint('🔧 Environment Configuration:');
      debugPrint('  OpenAI API: ${openAIApiKey.isNotEmpty ? "✓" : "✗"}');
      debugPrint('  Currency API: ${currencyApiKey.isNotEmpty ? "✓" : "✗"}');
      debugPrint('  Firebase API: ${firebaseApiKey.isNotEmpty ? "✓" : "✗"}');
    }
  }
}
