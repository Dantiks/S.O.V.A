import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message_entity.freezed.dart';
part 'chat_message_entity.g.dart';

enum MessageRole {
  user,
  assistant,
  system,
}

enum MessageType {
  text,
  voice,
  image,
  file,
}

@freezed
class ChatMessageEntity with _$ChatMessageEntity {
  const factory ChatMessageEntity({
    required String id,
    required String userId,
    required MessageRole role,
    required MessageType type,
    required String content,
    DateTime? timestamp,
    String? audioUrl,
    String? imageUrl,
    String? fileUrl,
    Map<String, dynamic>? metadata,
    @Default(false) bool isError,
    String? errorMessage,
  }) = _ChatMessageEntity;

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageEntityFromJson(json);
}
