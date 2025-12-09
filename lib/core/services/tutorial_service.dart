import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для управления туториалом/онбордингом
class TutorialService {
  static const String _tutorialCompletedKey = 'tutorial_completed';
  static const String _helperShownCountKey = 'helper_shown_count';
  
  /// Проверяет, был ли пройден туториал
  static Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialCompletedKey) ?? false;
  }
  
  /// Отмечает туториал как завершенный
  static Future<void> completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialCompletedKey, true);
  }
  
  /// Сброс туториала (для тестирования)
  static Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tutorialCompletedKey);
    await prefs.remove(_helperShownCountKey);
  }
  
  /// Получить количество показов помощника
  static Future<int> getHelperShownCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_helperShownCountKey) ?? 0;
  }
  
  /// Увеличить счетчик показов помощника
  static Future<void> incrementHelperShownCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = await getHelperShownCount();
    await prefs.setInt(_helperShownCountKey, count + 1);
  }
  
  /// Показать туториал с несколькими шагами
  static void showTutorial(
    BuildContext context, {
    required VoidCallback onComplete,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TutorialDialog(onComplete: onComplete),
    );
  }
}

/// Диалог с туториалом
class TutorialDialog extends StatefulWidget {
  final VoidCallback onComplete;
  
  const TutorialDialog({super.key, required this.onComplete});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  int _currentStep = 0;
  
  final List<TutorialStep> _steps = [
    TutorialStep(
      icon: Icons.account_balance_wallet,
      title: 'Добро пожаловать в FINER!',
      description: 'Ваш умный финансовый помощник для управления деньгами',
      color: Color(0xFF7A3DF2),
    ),
    TutorialStep(
      icon: Icons.dashboard,
      title: 'Главная панель',
      description: 'Здесь вы видите общий баланс, доходы и расходы за месяц',
      color: Color(0xFF4CAF50),
    ),
    TutorialStep(
      icon: Icons.add_circle,
      title: 'Быстрые действия',
      description: 'Быстро добавляйте доходы и расходы одним нажатием',
      color: Color(0xFF2196F3),
    ),
    TutorialStep(
      icon: Icons.chat_bubble,
      title: 'AI Помощник',
      description: 'Нажмите на иконку помощника для получения советов и аналитики',
      color: Color(0xFFFF9800),
    ),
    TutorialStep(
      icon: Icons.notifications_active,
      title: 'Уведомления',
      description: 'Получайте напоминания о платежах и важных событиях',
      color: Color(0xFFE91E63),
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      TutorialService.completeTutorial();
      Navigator.of(context).pop();
      widget.onComplete();
    }
  }

  void _skipTutorial() {
    TutorialService.completeTutorial();
    Navigator.of(context).pop();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF0f0f1e),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Иконка
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [step.color, step.color.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                step.icon,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            
            // Заголовок
            Text(
              step.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Описание
            Text(
              step.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Индикаторы прогресса
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == _currentStep ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: index == _currentStep
                        ? step.color
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Кнопки
            Row(
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: _skipTutorial,
                    child: Text(
                      'Пропустить',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: step.color,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentStep < _steps.length - 1 ? 'Далее' : 'Начать',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Модель шага туториала
class TutorialStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
