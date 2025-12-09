import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:finer/presentation/screens/settings/notification_settings_screen.dart';
import 'package:finer/presentation/screens/settings/export_data_screen.dart';
import 'package:finer/presentation/screens/settings/about_screen.dart';
import 'package:finer/presentation/screens/settings/widget_settings_screen.dart';
import 'package:finer/presentation/screens/pin/change_pin_screen.dart';
import 'package:finer/presentation/screens/home/tabs/profile_tab.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final biometric = ref.watch(biometricProvider);
    final accentColor = ref.watch(accentColorProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Настройки',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Приветствие
              Text(
                'Настройки приложения',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 24),

              // Безопасность
              _buildSectionHeader('Безопасность', Icons.security)
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.fingerprint,
                      iconColor: Colors.green,
                      title: 'Биометрия',
                      subtitle: 'Face ID / Touch ID',
                      trailing: Switch(
                        value: biometric,
                        onChanged: (v) =>
                            ref.read(biometricProvider.notifier).state = v,
                        activeColor: accentColor,
                      ),
                    ),
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    _buildSettingsTile(
                      icon: Icons.lock_outline,
                      iconColor: Colors.orange,
                      title: 'PIN-код',
                      subtitle: 'Изменить PIN-код',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChangePinScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 24),

              // Внешний вид
              _buildSectionHeader('Внешний вид', Icons.palette_outlined)
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.brightness_6_outlined,
                      iconColor: Colors.blue,
                      title: 'Тема',
                      subtitle: _getThemeName(themeMode),
                      onTap: () {
                        _showThemeDialog(context, ref, themeMode);
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    _buildSettingsTile(
                      icon: Icons.palette,
                      iconColor: accentColor,
                      title: 'Акцентный цвет',
                      subtitle: _getColorName(accentColor),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2),
                        ),
                      ),
                      onTap: () {
                        _showColorDialog(context, ref, accentColor);
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    _buildSettingsTile(
                      icon: Icons.text_fields,
                      iconColor: Colors.purple,
                      title: 'Размер шрифта',
                      subtitle: 'Средний',
                      onTap: () {
                        // TODO: Реализовать выбор размера шрифта
                      },
                    ),
                  ],
                ),
              ).animate(delay: 250.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 24),

              // Уведомления
              _buildSectionHeader('Уведомления', Icons.notifications_outlined)
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.notifications_active,
                      iconColor: Colors.red,
                      title: 'Push-уведомления',
                      subtitle: 'Настройка уведомлений',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate(delay: 350.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 24),

              // Виджеты
              _buildSectionHeader('Виджеты', Icons.widgets_outlined)
                  .animate(delay: 375.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.home_outlined,
                      iconColor: const Color(0xFF7A3DF2),
                      title: 'Виджет на рабочем столе',
                      subtitle: 'Настройка главного экрана',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WidgetSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate(delay: 387.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 24),

              // Данные
              _buildSectionHeader('Данные', Icons.storage_outlined)
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.cloud_download_outlined,
                      iconColor: Colors.cyan,
                      title: 'Экспорт данных',
                      subtitle: 'CSV/PDF экспорт',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ExportDataScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    _buildSettingsTile(
                      icon: Icons.storage,
                      iconColor: Colors.amber,
                      title: 'Очистить кэш',
                      subtitle: 'Освободить 45 МБ',
                      onTap: () async {
                        final confirm = await _showConfirmDialog(
                          context,
                          'Очистить кэш?',
                          'Это удалит временные файлы',
                        );
                        if (confirm && mounted) {
                          // TODO: Реализовать очистку кэша
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Кэш очищен'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ).animate(delay: 450.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
              const SizedBox(height: 24),

              // О приложении
              _buildSectionHeader('О приложении', Icons.info_outline)
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.2, end: 0),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.info,
                      iconColor: Colors.teal,
                      title: 'О приложении',
                      subtitle: 'FINER v1.0.0',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AboutScreen(),
                          ),
                        );
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    _buildSettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: Colors.indigo,
                      title: 'Политика конфиденциальности',
                      subtitle: 'Как мы используем ваши данные',
                      onTap: () {
                        // TODO: Открыть политику конфиденциальности
                      },
                    ),
                    Divider(color: Colors.white.withOpacity(0.1), height: 1),
                    _buildSettingsTile(
                      icon: Icons.description_outlined,
                      iconColor: Colors.brown,
                      title: 'Условия использования',
                      subtitle: 'Правила и условия',
                      onTap: () {
                        // TODO: Открыть условия использования
                      },
                    ),
                  ],
                ),
              ).animate(delay: 550.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
              
              const SizedBox(height: 40),
              
              // Версия приложения
              Center(
                child: Column(
                  children: [
                    Text(
                      'FINER',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Версия 1.0.0 (Build 1)',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7A3DF2), size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.6),
          fontSize: 13,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
      onTap: onTap,
    );
  }

  String _getThemeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Светлая';
      case ThemeMode.dark:
        return 'Тёмная';
      case ThemeMode.system:
        return 'Системная';
    }
  }

  String _getColorName(Color color) {
    if (color == const Color(0xFF7A3DF2)) return 'Фиолетовый';
    if (color == const Color(0xFF4CAF50)) return 'Зелёный';
    if (color == const Color(0xFFE91E63)) return 'Розовый';
    if (color == const Color(0xFF2196F3)) return 'Синий';
    if (color == const Color(0xFFFF9800)) return 'Оранжевый';
    return 'Пользовательский';
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, ThemeMode current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Выбор темы', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              title: 'Светлая',
              isSelected: current == ThemeMode.light,
              onTap: () {
                ref.read(themeProvider.notifier).state = ThemeMode.light;
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              title: 'Тёмная',
              isSelected: current == ThemeMode.dark,
              onTap: () {
                ref.read(themeProvider.notifier).state = ThemeMode.dark;
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              title: 'Системная',
              isSelected: current == ThemeMode.system,
              onTap: () {
                ref.read(themeProvider.notifier).state = ThemeMode.system;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorDialog(BuildContext context, WidgetRef ref, Color current) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Выбор цвета', style: TextStyle(color: Colors.white)),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _ColorOption(
              color: const Color(0xFF7A3DF2),
              label: 'Фиолетовый',
              onTap: () {
                ref.read(accentColorProvider.notifier).state =
                    const Color(0xFF7A3DF2);
                Navigator.pop(context);
              },
            ),
            _ColorOption(
              color: const Color(0xFF4CAF50),
              label: 'Зелёный',
              onTap: () {
                ref.read(accentColorProvider.notifier).state =
                    const Color(0xFF4CAF50);
                Navigator.pop(context);
              },
            ),
            _ColorOption(
              color: const Color(0xFFE91E63),
              label: 'Розовый',
              onTap: () {
                ref.read(accentColorProvider.notifier).state =
                    const Color(0xFFE91E63);
                Navigator.pop(context);
              },
            ),
            _ColorOption(
              color: const Color(0xFF2196F3),
              label: 'Синий',
              onTap: () {
                ref.read(accentColorProvider.notifier).state =
                    const Color(0xFF2196F3);
                Navigator.pop(context);
              },
            ),
            _ColorOption(
              color: const Color(0xFFFF9800),
              label: 'Оранжевый',
              onTap: () {
                ref.read(accentColorProvider.notifier).state =
                    const Color(0xFFFF9800);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

class _ThemeOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF7A3DF2))
          : const Icon(Icons.circle_outlined, color: Colors.white38),
      onTap: onTap,
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
