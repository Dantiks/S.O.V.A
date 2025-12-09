import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';
part 'notification_entity.g.dart';

enum NotificationType {
  transaction,
  goal,
  recurring,
  budget,
  system,
}

@freezed
class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    required String title,
    required String message,
    required NotificationType type,
    required DateTime createdAt,
    @Default(false) bool isRead,
    String? actionData,
    String? icon,
  }) = _NotificationEntity;

  factory NotificationEntity.fromJson(Map<String, dynamic> json) =>
      _$NotificationEntityFromJson(json);
}
