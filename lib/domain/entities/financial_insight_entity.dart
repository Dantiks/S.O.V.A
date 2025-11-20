import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_insight_entity.freezed.dart';
part 'financial_insight_entity.g.dart';

enum InsightType {
  spending,
  saving,
  budget,
  anomaly,
  prediction,
  recommendation,
}

enum InsightPriority {
  low,
  medium,
  high,
  critical,
}

@freezed
class FinancialInsightEntity with _$FinancialInsightEntity {
  const factory FinancialInsightEntity({
    required String id,
    required String userId,
    required InsightType type,
    required InsightPriority priority,
    required String title,
    required String description,
    required DateTime generatedAt,
    String? actionText,
    String? actionRoute,
    Map<String, dynamic>? data,
    @Default(false) bool isRead,
    @Default(false) bool isDismissed,
    DateTime? expiresAt,
  }) = _FinancialInsightEntity;

  factory FinancialInsightEntity.fromJson(Map<String, dynamic> json) =>
      _$FinancialInsightEntityFromJson(json);
}
