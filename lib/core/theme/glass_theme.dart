import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Стеклянная дизайн-система для S.O.V.A
class GlassTheme {
  // Цвета стекла
  static const glassLight = Color(0x33FFFFFF);
  static const glassMedium = Color(0x22FFFFFF);
  static const glassDark = Color(0x11FFFFFF);
  static const glassAccent = Color(0x447A3DF2);
  
  // Градиенты
  static const glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF),
      Color(0x11FFFFFF),
    ],
  );
  
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7A3DF2),
      Color(0xFF5E2BB8),
    ],
  );
  
  // Эффект размытия
  static const blurStrength = 10.0;
  static const blurStrongStrength = 20.0;
  
  // Тени
  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(-5, -5),
    ),
  ];
  
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: const Color(0xFF7A3DF2).withOpacity(0.3),
      blurRadius: 30,
      spreadRadius: 5,
    ),
  ];
}

/// Стеклянный контейнер с размытием
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final double blur;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.gradient,
    this.blur = GlassTheme.blurStrength,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        boxShadow: boxShadow ?? GlassTheme.glassShadow,
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: gradient ?? GlassTheme.glassGradient,
              borderRadius: borderRadius ?? BorderRadius.circular(20),
              border: border ?? Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Кнопка с water ripple эффектом
class WaterRippleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final Color? rippleColor;

  const WaterRippleButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
    this.gradient,
    this.rippleColor,
  });

  @override
  State<WaterRippleButton> createState() => _WaterRippleButtonState();
}

class _WaterRippleButtonState extends State<WaterRippleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  Offset? _tapPosition;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );
    
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(TapDownDetails details) {
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    setState(() {
      _tapPosition = details.localPosition;
    });
    _controller.forward(from: 0.0).then((_) {
      widget.onPressed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GlassContainer(
              width: widget.width,
              height: widget.height,
              padding: widget.padding ?? const EdgeInsets.all(16),
              borderRadius: widget.borderRadius,
              gradient: widget.gradient ?? GlassTheme.accentGradient,
              child: Stack(
                children: [
                  // Water ripple effect
                  if (_tapPosition != null)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: WaterRipplePainter(
                          progress: _rippleAnimation.value,
                          center: _tapPosition!,
                          color: widget.rippleColor ??
                              Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ),
                  // Button content
                  Center(child: widget.child),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Painter для water ripple эффекта
class WaterRipplePainter extends CustomPainter {
  final double progress;
  final Offset center;
  final Color color;

  WaterRipplePainter({
    required this.progress,
    required this.center,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0.0) return;

    final maxRadius = (size.width > size.height ? size.width : size.height) * 1.5;
    final radius = maxRadius * progress;
    
    // Создаем несколько волн для эффекта воды
    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress - (i * 0.1)).clamp(0.0, 1.0);
      final waveRadius = maxRadius * waveProgress;
      final opacity = (1.0 - waveProgress) * 0.5;
      
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      
      canvas.drawCircle(center, waveRadius, paint);
    }
    
    // Основная волна
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity((1.0 - progress) * 0.4),
          color.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(WaterRipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Стеклянная карточка
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = GlassContainer(
      padding: padding ?? const EdgeInsets.all(16),
      margin: margin,
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: card,
      );
    }

    return card;
  }
}

/// Стеклянный AppBar
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: centerTitle,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: leading,
            actions: actions,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
