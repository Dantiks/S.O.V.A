import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sova/core/constants/app_colors.dart';
import 'package:sova/core/constants/app_text_styles.dart';
import 'package:sova/presentation/providers/chat_provider.dart';
import 'package:sova/domain/entities/chat_message_entity.dart';
import 'package:sova/presentation/widgets/glassmorphic_container.dart';

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.purpleGradient,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'S.O.V.A AI',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                Text(
                  chatState.isLoading ? 'Печатает...' : 'Онлайн',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              ref.read(chatControllerProvider.notifier).clearMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatState.messages[index];
                      return _buildMessageBubble(message)
                          .animate()
                          .fadeIn(duration: 300.ms)
                          .slideY(begin: 0.2, end: 0);
                    },
                  ),
          ),

          // Loading Indicator
          if (chatState.isLoading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.purple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI думает...',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Voice Input Button
                  GestureDetector(
                    onTap: () {
                      if (chatState.isListening) {
                        ref.read(chatControllerProvider.notifier).stopVoiceInput();
                      } else {
                        ref.read(chatControllerProvider.notifier).startVoiceInput();
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: chatState.isListening
                            ? AppColors.error
                            : AppColors.darkCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        chatState.isListening ? Icons.stop : Icons.mic,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Text Input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Спросите что-нибудь...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.gray500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Send Button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppColors.purpleShadow,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.purpleGradient,
              boxShadow: AppColors.glowShadow,
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 50,
              color: AppColors.white,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: AppColors.white.withOpacity(0.3)),
          const SizedBox(height: 24),
          Text(
            'Привет! Я S.O.V.A',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Ваш персональный финансовый ассистент.\nЗадайте мне любой вопрос!',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 32),
          _buildSuggestions(),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      'Проанализируй мои расходы',
      'Как сэкономить деньги?',
      'Покажи статистику',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((suggestion) {
        return GestureDetector(
          onTap: () {
            _messageController.text = suggestion;
            _sendMessage();
          },
          child: GlassmorphicContainer(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Text(
                suggestion,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.gray300,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMessageBubble(ChatMessageEntity message) {
    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: isUser
                    ? AppColors.purpleGradient
                    : null,
                color: isUser ? null : AppColors.darkCard,
                borderRadius: BorderRadius.circular(16).copyWith(
                  topRight: isUser ? const Radius.circular(4) : null,
                  topLeft: !isUser ? const Radius.circular(4) : null,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                      height: 1.5,
                    ),
                  ),
                  if (!isUser) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(chatControllerProvider.notifier)
                            .speakMessage(message.content);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.volume_up,
                            size: 16,
                            color: AppColors.purple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Озвучить',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.purple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    ref.read(chatControllerProvider.notifier).sendMessage(message);
    _messageController.clear();

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }
}
