import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_entity.freezed.dart';
part 'transaction_entity.g.dart';

enum TransactionType {
  income,
  expense,
  transfer,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

@freezed
class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    required String id,
    required String accountId,
    required String userId,
    required TransactionType type,
    required double amount,
    required String currency,
    required String category,
    required DateTime date,
    required TransactionStatus status,
    String? description,
    String? merchant,
    String? location,
    String? notes,
    String? receiptUrl,
    String? toAccountId,
    String? fromAccountId,
    Map<String, dynamic>? metadata,
    @Default(false) bool isRecurring,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TransactionEntity;

  factory TransactionEntity.fromJson(Map<String, dynamic> json) =>
      _$TransactionEntityFromJson(json);
}
