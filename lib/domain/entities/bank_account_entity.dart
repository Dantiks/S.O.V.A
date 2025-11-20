import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_account_entity.freezed.dart';
part 'bank_account_entity.g.dart';

@freezed
class BankAccountEntity with _$BankAccountEntity {
  const factory BankAccountEntity({
    required String id,
    required String userId,
    required String bankName,
    required String accountNumber,
    required String accountType,
    required double balance,
    required String currency,
    String? accountHolderName,
    String? iban,
    String? swift,
    String? cardNumber,
    String? cardType,
    DateTime? expiryDate,
    @Default(true) bool isActive,
    @Default(false) bool isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
  }) = _BankAccountEntity;

  factory BankAccountEntity.fromJson(Map<String, dynamic> json) =>
      _$BankAccountEntityFromJson(json);
}
