import 'package:freezed_annotation/freezed_annotation.dart';

part 'savings_goal_entity.freezed.dart';
part 'savings_goal_entity.g.json';

@freezed
class SavingsGoalEntity with _$SavingsGoalEntity {
  const factory SavingsGoalEntity({
    required String id,
    required String userId,
    required String name,
    required String description,
    required double targetAmount,
    required double currentAmount,
    required DateTime startDate,
    required DateTime targetDate,
    required String category,
    required String iconName,
    required String colorHex,
    @Default(false) bool isCompleted,
    @Default(false) bool autoSave,
    double? monthlyContribution,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SavingsGoalEntity;

  factory SavingsGoalEntity.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalEntityFromJson(json);
}

extension SavingsGoalX on SavingsGoalEntity {
  double get progress => currentAmount / targetAmount;
  
  int get daysRemaining {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }
  
  double get requiredMonthlyContribution {
    final monthsRemaining = daysRemaining / 30;
    final amountNeeded = targetAmount - currentAmount;
    return monthsRemaining > 0 ? amountNeeded / monthsRemaining : amountNeeded;
  }
  
  bool get isOnTrack {
    if (monthlyContribution == null) return false;
    return monthlyContribution! >= requiredMonthlyContribution;
  }
}
