class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'S.O.V.A';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered financial assistant';

  // API Configuration
  static const String baseUrl = 'https://api.sova.kg/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String themeKey = 'theme_mode';
  static const String accentColorKey = 'accent_color';
  static const String biometricEnabledKey = 'biometric_enabled';
  static const String pinCodeKey = 'pin_code';
  static const String languageKey = 'language';
  static const String currencyKey = 'currency';
  static const String onboardingCompletedKey = 'onboarding_completed';

  // Hive Boxes
  static const String userBox = 'user_box';
  static const String accountsBox = 'accounts_box';
  static const String transactionsBox = 'transactions_box';
  static const String categoriesBox = 'categories_box';
  static const String settingsBox = 'settings_box';
  static const String chatHistoryBox = 'chat_history_box';

  // Security
  static const String encryptionKey = 'sova_encryption_key_v1';
  static const int pinCodeLength = 6;
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);

  // AI Configuration
  static const String aiModelName = 'gemini-pro';
  static const int maxChatHistoryLength = 50;
  static const Duration aiResponseTimeout = Duration(seconds: 60);

  // Pagination
  static const int defaultPageSize = 20;
  static const int transactionsPageSize = 50;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  static const Duration splashDuration = Duration(seconds: 3);

  // Supported Banks in Kyrgyzstan
  static const List<String> supportedBanks = [
    'Optima Bank',
    'KICB',
    'DemirBank',
    'DosCredoBank',
    'Halyk Bank',
    'Bai Tushum',
    'Keremet Bank',
    'MBank',
    'Kapital Bank',
    'eLCARD',
  ];

  // Currencies
  static const String defaultCurrency = 'KGS';
  static const List<String> supportedCurrencies = [
    'KGS',
    'USD',
    'EUR',
    'RUB',
    'KZT',
  ];

  // Transaction Categories
  static const List<String> expenseCategories = [
    'Продукты',
    'Транспорт',
    'Развлечения',
    'Здоровье',
    'Образование',
    'Коммунальные услуги',
    'Одежда',
    'Рестораны',
    'Путешествия',
    'Другое',
  ];

  static const List<String> incomeCategories = [
    'Зарплата',
    'Бизнес',
    'Инвестиции',
    'Подарки',
    'Другое',
  ];

  // Widget Configuration
  static const String widgetBalanceId = 'sova_balance_widget';
  static const String widgetAdviceId = 'sova_advice_widget';
  static const String widgetChartId = 'sova_chart_widget';
  static const Duration widgetUpdateInterval = Duration(minutes: 15);

  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = ['pdf', 'csv', 'xlsx'];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
}
