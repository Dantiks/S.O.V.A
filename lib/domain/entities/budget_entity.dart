import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_entity.freezed.dart';
part 'budget_entity.g.dart';

enum BudgetPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

@freezed
class BudgetEntity with _$BudgetEntity {
  const factory BudgetEntity({
    required String id,
    required String userId,
    required String categoryId,
    required double amount,
    required String currency,
    required BudgetPeriod period,
    required DateTime startDate,
    DateTime? endDate,
    @Default(0.0) double spent,
    @Default(true) bool isActive,
    @Default(true) bool notifyOnExceed,
    @Default(0.8) double warningThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BudgetEntity;

  factory BudgetEntity.fromJson(Map<String, dynamic> json) =>
      _$BudgetEntityFromJson(json);
}
