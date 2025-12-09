import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_account_entity.freezed.dart';
part 'family_account_entity.g.dart';

enum FamilyRole { admin, member, viewer }

@freezed
class FamilyAccountEntity with _$FamilyAccountEntity {
  const factory FamilyAccountEntity({
    required String id,
    required String name,
    required String createdBy,
    required List<FamilyMember> members,
    required List<String> sharedAccountIds,
    required List<String> sharedGoalIds,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _FamilyAccountEntity;

  factory FamilyAccountEntity.fromJson(Map<String, dynamic> json) =>
      _$FamilyAccountEntityFromJson(json);
}

@freezed
class FamilyMember with _$FamilyMember {
  const factory FamilyMember({
    required String userId,
    required String displayName,
    required FamilyRole role,
    String? photoUrl,
    DateTime? joinedAt,
  }) = _FamilyMember;

  factory FamilyMember.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberFromJson(json);
}
