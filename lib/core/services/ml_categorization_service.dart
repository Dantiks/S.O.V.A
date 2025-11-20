import 'dart:math';

/// ML-based transaction categorization service
class MLCategorizationService {
  // Merchant to category mapping (can be replaced with actual ML model)
  final Map<String, String> _merchantCategories = {
    'netflix': 'entertainment',
    'spotify': 'entertainment',
    'uber': 'transport',
    'bolt': 'transport',
    'yandex': 'transport',
    'globus': 'groceries',
    'narodniy': 'groceries',
    'bishkek park': 'groceries',
    'starbucks': 'restaurants',
    'mcdonalds': 'restaurants',
    'kfc': 'restaurants',
    'zara': 'shopping',
    'h&m': 'shopping',
    'adidas': 'shopping',
    'pharmacy': 'health',
    'apteka': 'health',
    'fitness': 'health',
  };

  final Map<String, List<String>> _categoryKeywords = {
    'groceries': ['продукты', 'магазин', 'супермаркет', 'market'],
    'transport': ['такси', 'бензин', 'топливо', 'транспорт', 'taxi'],
    'restaurants': ['ресторан', 'кафе', 'еда', 'restaurant', 'cafe'],
    'entertainment': ['кино', 'театр', 'развлечения', 'cinema'],
    'health': ['аптека', 'врач', 'медицина', 'pharmacy', 'doctor'],
    'shopping': ['одежда', 'обувь', 'магазин', 'clothes', 'shoes'],
    'utilities': ['коммунальные', 'свет', 'вода', 'газ', 'utilities'],
    'education': ['школа', 'курсы', 'обучение', 'education'],
  };

  /// Predict category for a transaction
  Future<String> predictCategory({
    required String description,
    String? merchantName,
    double? amount,
  }) async {
    // 1. Check merchant name
    if (merchantName != null) {
      final merchant = merchantName.toLowerCase();
      for (var entry in _merchantCategories.entries) {
        if (merchant.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    // 2. Check description keywords
    final desc = description.toLowerCase();
    for (var entry in _categoryKeywords.entries) {
      for (var keyword in entry.value) {
        if (desc.contains(keyword)) {
          return entry.key;
        }
      }
    }

    // 3. Amount-based heuristics
    if (amount != null) {
      if (amount < 100) return 'transport';
      if (amount > 10000) return 'shopping';
    }

    return 'other';
  }

  /// Get category confidence score
  Future<double> getCategoryConfidence({
    required String description,
    required String predictedCategory,
  }) async {
    final desc = description.toLowerCase();
    final keywords = _categoryKeywords[predictedCategory] ?? [];
    
    int matches = 0;
    for (var keyword in keywords) {
      if (desc.contains(keyword)) matches++;
    }

    return matches > 0 ? min(matches / keywords.length, 1.0) : 0.5;
  }

  /// Learn from user corrections
  Future<void> learnFromCorrection({
    required String description,
    required String merchantName,
    required String correctCategory,
  }) async {
    // Store user corrections for future predictions
    _merchantCategories[merchantName.toLowerCase()] = correctCategory;
  }

  /// Get suggested subcategories
  List<String> getSubcategories(String category) {
    final subcategories = {
      'groceries': ['Супермаркет', 'Рынок', 'Мини-маркет'],
      'transport': ['Такси', 'Бензин', 'Общественный транспорт'],
      'restaurants': ['Фастфуд', 'Кафе', 'Ресторан'],
      'entertainment': ['Кино', 'Концерт', 'Игры'],
      'health': ['Аптека', 'Врач', 'Анализы'],
      'shopping': ['Одежда', 'Обувь', 'Электроника'],
    };

    return subcategories[category] ?? [];
  }

  /// Analyze spending patterns
  Future<Map<String, dynamic>> analyzeSpendingPatterns(
    List<Map<String, dynamic>> transactions,
  ) async {
    final categoryTotals = <String, double>{};
    final categoryCount = <String, int>{};

    for (var t in transactions) {
      final category = t['category'] as String;
      final amount = t['amount'] as double;

      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return {
      'totals': categoryTotals,
      'counts': categoryCount,
      'averages': categoryTotals.map(
        (k, v) => MapEntry(k, v / categoryCount[k]!),
      ),
    };
  }
}
