import 'package:flutter/material.dart';
import 'dart:math' as math;

class QuickActionsFAB extends StatefulWidget {
  const QuickActionsFAB({super.key});

  @override
  State<QuickActionsFAB> createState() => _QuickActionsFABState();
}

class _QuickActionsFABState extends State<QuickActionsFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded) ...[
          _buildActionButton(
            icon: Icons.add,
            label: 'Доход',
            color: Colors.green,
            onTap: () => _handleAction('income'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.remove,
            label: 'Расход',
            color: Colors.red,
            onTap: () => _handleAction('expense'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.receipt_long,
            label: 'Сканировать чек',
            color: Colors.blue,
            onTap: () => _handleAction('scan'),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.chat,
            label: 'AI-Чат',
            color: Colors.purple,
            onTap: () => _handleAction('chat'),
          ),
          const SizedBox(height: 16),
        ],
        FloatingActionButton(
          onPressed: _toggle,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * math.pi / 4,
                child: Icon(_isExpanded ? Icons.close : Icons.add),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            heroTag: label,
            backgroundColor: color,
            onPressed: onTap,
            child: Icon(icon),
          ),
        ],
      ),
    );
  }

  void _handleAction(String action) {
    _toggle();
    // Handle action
    switch (action) {
      case 'income':
        // Navigate to add income
        break;
      case 'expense':
        // Navigate to add expense
        break;
      case 'scan':
        // Navigate to scan receipt
        break;
      case 'chat':
        // Navigate to AI chat
        break;
    }
  }
}
