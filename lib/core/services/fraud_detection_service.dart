import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FraudRiskLevel { low, medium, high, critical }

class FraudAlert {
  final String id;
  final String transactionId;
  final FraudRiskLevel riskLevel;
  final String reason;
  final DateTime detectedAt;
  final Map<String, dynamic> metadata;

  FraudAlert({
    required this.id,
    required this.transactionId,
    required this.riskLevel,
    required this.reason,
    required this.detectedAt,
    this.metadata = const {},
  });
}

class FraudDetectionService {
  final List<FraudAlert> _alerts = [];

  Future<FraudAlert?> analyzeTransaction(Map<String, dynamic> transaction) async {
    final amount = transaction['amount'] as double;
    final category = transaction['category'] as String;
    final location = transaction['location'] as String?;

    // Rule 1: Unusually large amount
    if (amount > 100000) {
      return _createAlert(
        transaction['id'],
        FraudRiskLevel.high,
        'Необычно большая сумма транзакции',
        {'amount': amount},
      );
    }

    // Rule 2: Multiple transactions in short time
    // Rule 3: Unusual location
    if (location != null && !_isKnownLocation(location)) {
      return _createAlert(
        transaction['id'],
        FraudRiskLevel.medium,
        'Транзакция из необычной локации',
        {'location': location},
      );
    }

    // Rule 4: Unusual category for user
    if (_isUnusualCategory(category)) {
      return _createAlert(
        transaction['id'],
        FraudRiskLevel.low,
        'Необычная категория транзакции',
        {'category': category},
      );
    }

    return null;
  }

  FraudAlert _createAlert(
    String transactionId,
    FraudRiskLevel level,
    String reason,
    Map<String, dynamic> metadata,
  ) {
    final alert = FraudAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      transactionId: transactionId,
      riskLevel: level,
      reason: reason,
      detectedAt: DateTime.now(),
      metadata: metadata,
    );
    _alerts.add(alert);
    return alert;
  }

  bool _isKnownLocation(String location) {
    // Check against user's known locations
    return true; // Placeholder
  }

  bool _isUnusualCategory(String category) {
    // Check against user's spending patterns
    return false; // Placeholder
  }

  List<FraudAlert> getAlerts() => List.unmodifiable(_alerts);
  
  void clearAlert(String alertId) {
    _alerts.removeWhere((a) => a.id == alertId);
  }
}

final fraudDetectionServiceProvider = Provider((ref) => FraudDetectionService());
