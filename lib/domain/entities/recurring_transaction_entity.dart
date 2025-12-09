import 'package:freezed_annotation/freezed_annotation.dart';

part 'recurring_transaction_entity.freezed.dart';
part 'recurring_transaction_entity.g.dart';

enum RecurringFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
  quarterly,
  yearly,
}

@freezed
class RecurringTransactionEntity with _$RecurringTransactionEntity {
  const factory RecurringTransactionEntity({
    required String id,
    required String userId,
    required String name,
    required double amount,
    required String category,
    required RecurringFrequency frequency,
    required DateTime startDate,
    DateTime? endDate,
    required String accountId,
    @Default(true) bool isActive,
    @Default(true) bool notifyBefore,
    @Default(1) int notifyDaysBefore,
    DateTime? lastProcessedDate,
    DateTime? nextDueDate,
    String? description,
    String? merchantName,
    DateTime? createdAt,
  }) = _RecurringTransactionEntity;

  factory RecurringTransactionEntity.fromJson(Map<String, dynamic> json) =>
      _$RecurringTransactionEntityFromJson(json);
}

extension RecurringTransactionX on RecurringTransactionEntity {
  DateTime calculateNextDueDate() {
    final base = lastProcessedDate ?? startDate;
    switch (frequency) {
      case RecurringFrequency.daily:
        return base.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return base.add(const Duration(days: 7));
      case RecurringFrequency.biweekly:
        return base.add(const Duration(days: 14));
      case RecurringFrequency.monthly:
        return DateTime(base.year, base.month + 1, base.day);
      case RecurringFrequency.quarterly:
        return DateTime(base.year, base.month + 3, base.day);
      case RecurringFrequency.yearly:
        return DateTime(base.year + 1, base.month, base.day);
    }
  }
  
  bool get isDueToday {
    if (nextDueDate == null) return false;
    final now = DateTime.now();
    return nextDueDate!.year == now.year &&
           nextDueDate!.month == now.month &&
           nextDueDate!.day == now.day;
  }
  
  int get daysUntilDue {
    if (nextDueDate == null) return 0;
    return nextDueDate!.difference(DateTime.now()).inDays;
  }
}
