import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Плавающая кнопка AI помощника
class AIHelperButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool showPulse;
  
  const AIHelperButton({
    super.key,
    required this.onTap,
    this.showPulse = false,
  });

  @override
  State<AIHelperButton> createState() => _AIHelperButtonState();
}

class _AIHelperButtonState extends State<AIHelperButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Пульсирующий эффект
          if (widget.showPulse)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 60 + (_controller.value * 20),
                  height: 60 + (_controller.value * 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7A3DF2).withOpacity(0.3 * (1 - _controller.value)),
                        const Color(0xFF5A2DB2).withOpacity(0.2 * (1 - _controller.value)),
                      ],
                    ),
                  ),
                );
              },
            ),
          
          // Основная кнопка
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF7A3DF2), Color(0xFF5A2DB2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7A3DF2).withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.assistant,
              color: Colors.white,
              size: 28,
            ),
          ),
          
          // Индикатор активности
          if (widget.showPulse)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent,
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .fadeIn(duration: 800.ms)
                .then()
                .fadeOut(duration: 800.ms),
            ),
        ],
      ),
    ).animate()
      .scale(
        duration: 300.ms,
        curve: Curves.easeOut,
      );
  }
}

/// Миниатюрный помощник для встраивания в AppBar
class AIHelperMiniButton extends StatelessWidget {
  final VoidCallback onTap;
  
  const AIHelperMiniButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF7A3DF2), Color(0xFF5A2DB2)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7A3DF2).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.assistant,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
