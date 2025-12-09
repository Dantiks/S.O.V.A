import 'package:dio/dio.dart';
import 'package:finer/core/config/env_config.dart';

class CurrencyService {
  final Dio _dio = Dio();
  late final String _apiKey;
  final String _baseUrl = 'https://v6.exchangerate-api.com/v6';

  CurrencyService({String? apiKey}) {
    _apiKey = apiKey ?? EnvConfig.currencyApiKey;
    
    if (_apiKey.isEmpty) {
      throw Exception('Currency API key не настроен! Добавьте CURRENCY_API_KEY в .env файл');
    }
  }

  // Получить курсы валют относительно базовой валюты
  Future<Map<String, double>> getExchangeRates({String baseCurrency = 'KGS'}) async {
    try {
      final response = await _dio.get('$_baseUrl/$_apiKey/latest/$baseCurrency');
      
      if (response.statusCode == 200 && response.data['result'] == 'success') {
        final rates = response.data['conversion_rates'] as Map<String, dynamic>;
        return rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
      }
      
      throw Exception('Failed to load exchange rates');
    } catch (e) {
      print('Currency API Error: $e');
      rethrow;
    }
  }

  // Конвертировать сумму из одной валюты в другую
  Future<double> convertCurrency({
    required double amount,
    required String from,
    required String to,
  }) async {
    try {
      final response = await _dio.get('$_baseUrl/$_apiKey/pair/$from/$to/$amount');
      
      if (response.statusCode == 200 && response.data['result'] == 'success') {
        return (response.data['conversion_result'] as num).toDouble();
      }
      
      throw Exception('Failed to convert currency');
    } catch (e) {
      print('Currency Conversion Error: $e');
      rethrow;
    }
  }

  // Получить популярные курсы для КР
  Future<Map<String, double>> getKyrgyzstanRates() async {
    try {
      final rates = await getExchangeRates(baseCurrency: 'KGS');
      
      // Возвращаем только популярные валюты
      return {
        'USD': rates['USD'] ?? 0.0,
        'EUR': rates['EUR'] ?? 0.0,
        'RUB': rates['RUB'] ?? 0.0,
        'KZT': rates['KZT'] ?? 0.0,
        'CNY': rates['CNY'] ?? 0.0,
        'TRY': rates['TRY'] ?? 0.0,
      };
    } catch (e) {
      print('Error getting Kyrgyzstan rates: $e');
      // Возвращаем примерные курсы в случае ошибки
      return {
        'USD': 0.0112,
        'EUR': 0.0103,
        'RUB': 1.08,
        'KZT': 5.12,
        'CNY': 0.081,
        'TRY': 0.38,
      };
    }
  }

  // Получить курс конкретной валюты к сому
  Future<double> getRateToKGS(String currency) async {
    try {
      final response = await _dio.get('$_baseUrl/$_apiKey/pair/$currency/KGS');
      
      if (response.statusCode == 200 && response.data['result'] == 'success') {
        return (response.data['conversion_rate'] as num).toDouble();
      }
      
      throw Exception('Failed to get rate');
    } catch (e) {
      print('Error getting rate for $currency: $e');
      return 0.0;
    }
  }

  // Форматировать валюту с символом
  String formatCurrency(double amount, String currency) {
    final symbols = {
      'KGS': '₸',
      'USD': '\$',
      'EUR': '€',
      'RUB': '₽',
      'KZT': '₸',
      'CNY': '¥',
      'TRY': '₺',
    };

    final symbol = symbols[currency] ?? currency;
    return '${amount.toStringAsFixed(2)} $symbol';
  }

  // Получить название валюты на русском
  String getCurrencyName(String code) {
    final names = {
      'KGS': 'Кыргызский сом',
      'USD': 'Доллар США',
      'EUR': 'Евро',
      'RUB': 'Российский рубль',
      'KZT': 'Казахстанский тенге',
      'CNY': 'Китайский юань',
      'TRY': 'Турецкая лира',
    };

    return names[code] ?? code;
  }

  // Получить флаг страны (эмодзи)
  String getCurrencyFlag(String code) {
    final flags = {
      'KGS': '🇰🇬',
      'USD': '🇺🇸',
      'EUR': '🇪🇺',
      'RUB': '🇷🇺',
      'KZT': '🇰🇿',
      'CNY': '🇨🇳',
      'TRY': '🇹🇷',
    };

    return flags[code] ?? '🌍';
  }
}
