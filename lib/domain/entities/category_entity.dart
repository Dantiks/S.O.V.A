import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:finer/domain/entities/transaction_entity.dart';

part 'category_entity.freezed.dart';
part 'category_entity.g.dart';

@freezed
class CategoryEntity with _$CategoryEntity {
  const factory CategoryEntity({
    required String id,
    required String name,
    required String icon,
    required String color,
    required TransactionType type,
    String? parentId,
    @Default(0) int order,
    @Default(true) bool isActive,
    @Default(false) bool isCustom,
    DateTime? createdAt,
  }) = _CategoryEntity;

  factory CategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoryEntityFromJson(json);
}
