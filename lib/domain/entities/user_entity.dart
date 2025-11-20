import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String id,
    required String email,
    required String displayName,
    String? photoUrl,
    String? phoneNumber,
    @Default(false) bool emailVerified,
    @Default('KGS') String preferredCurrency,
    @Default('ru') String preferredLanguage,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}
