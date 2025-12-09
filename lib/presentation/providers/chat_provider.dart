import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/services/openai_service.dart';
// import 'package:finer/core/services/speech_service.dart';
import 'package:finer/domain/entities/chat_message_entity.dart';

// Services
final aiServiceProvider = Provider<OpenAIService>((ref) => OpenAIService());
// final speechServiceProvider = Provider<SpeechService>((ref) => SpeechService());

// Chat State
class ChatState {
  final List<ChatMessageEntity> messages;
  final bool isLoading;
  final bool isListening;
  final bool isSpeaking;
  final String? error;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isListening = false,
    this.isSpeaking = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessageEntity>? messages,
    bool? isLoading,
    bool? isListening,
    bool? isSpeaking,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      error: error,
    );
  }
}

// Chat Controller
class ChatController extends StateNotifier<ChatState> {
  final OpenAIService _aiService;
  // final SpeechService _speechService;

  ChatController(this._aiService) : super(ChatState());

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessageEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user',
      role: MessageRole.user,
      type: MessageType.text,
      content: message,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
      error: null,
    );

    try {
      // Get AI response
      final response = await _aiService.sendMessage(message);

      // Add assistant message
      final assistantMessage = ChatMessageEntity(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        userId: 'current_user',
        role: MessageRole.assistant,
        type: MessageType.text,
        content: response,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> startVoiceInput() async {
    // Temporarily disabled
    state = state.copyWith(isListening: false);
  }

  Future<void> stopVoiceInput() async {
    // Temporarily disabled
    state = state.copyWith(isListening: false);
  }

  Future<void> speakMessage(String message) async {
    // Temporarily disabled
    state = state.copyWith(isSpeaking: false);
  }

  Future<void> stopSpeaking() async {
    // Temporarily disabled
    state = state.copyWith(isSpeaking: false);
  }

  void clearMessages() {
    _aiService.clearHistory();
    state = ChatState();
  }
}

final chatControllerProvider =
    StateNotifierProvider<ChatController, ChatState>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  // final speechService = ref.watch(speechServiceProvider);
  return ChatController(aiService);
});
