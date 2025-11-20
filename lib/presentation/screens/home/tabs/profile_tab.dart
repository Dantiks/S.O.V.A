import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/core/constants/app_colors.dart';
import 'package:sova/core/constants/app_text_styles.dart';
import 'package:sova/presentation/providers/auth_provider.dart';
import 'package:sova/presentation/providers/theme_provider.dart';
import 'package:sova/presentation/widgets/glassmorphic_container.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
      ),
      body: userAsync.when(
        data: (user) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // User Info
            _buildUserInfo(user?.displayName ?? 'Пользователь', user?.email ?? ''),
            const SizedBox(height: 24),

            // Settings Sections
            _buildSettingsSection(
              'Настройки приложения',
              [
                _buildSettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Тема',
                  subtitle: 'Темная',
                  onTap: () => _showThemeDialog(context, ref),
                ),
                _buildSettingsTile(
                  icon: Icons.color_lens_outlined,
                  title: 'Цвет акцента',
                  subtitle: 'Фиолетовый',
                  onTap: () => _showColorPicker(context, ref),
                ),
                _buildSettingsTile(
                  icon: Icons.language_outlined,
                  title: 'Язык',
                  subtitle: 'Русский',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.attach_money_outlined,
                  title: 'Валюта',
                  subtitle: 'KGS',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSettingsSection(
              'Безопасность',
              [
                _buildSettingsTile(
                  icon: Icons.fingerprint,
                  title: 'Биометрия',
                  subtitle: 'Face ID включен',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.purple,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'PIN-код',
                  subtitle: 'Изменить PIN-код',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.security_outlined,
                  title: 'Двухфакторная аутентификация',
                  subtitle: 'Не настроена',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSettingsSection(
              'Уведомления',
              [
                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push-уведомления',
                  subtitle: 'Включены',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {},
                    activeColor: AppColors.purple,
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.email_outlined,
                  title: 'Email-уведомления',
                  subtitle: 'Отключены',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {},
                    activeColor: AppColors.purple,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSettingsSection(
              'О приложении',
              [
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'Версия',
                  subtitle: '1.0.0',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Условия использования',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Политика конфиденциальности',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Помощь и поддержка',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton(
              onPressed: () {
                ref.read(authControllerProvider.notifier).signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Выйти из аккаунта'),
            ),

            const SizedBox(height: 40),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildUserInfo(String name, String email) {
    return GlassmorphicContainer(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.purpleGradient,
              ),
              child: Center(
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: AppTextStyles.displaySmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              color: AppColors.purple,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              color: AppColors.gray400,
            ),
          ),
        ),
        GlassmorphicContainer(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.purple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppColors.purple,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.gray400,
              ),
            )
          : null,
      trailing: trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.gray400,
            size: 16,
          ),
      onTap: onTap,
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: Text(
          'Выберите тему',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, ref, 'Темная', AppThemeMode.dark),
            _buildThemeOption(context, ref, 'Светлая', AppThemeMode.light),
            _buildThemeOption(context, ref, 'Системная', AppThemeMode.system),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String label,
    AppThemeMode mode,
  ) {
    final currentMode = ref.watch(themeControllerProvider).themeMode;
    return RadioListTile<AppThemeMode>(
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
        ),
      ),
      value: mode,
      groupValue: currentMode,
      activeColor: AppColors.purple,
      onChanged: (value) {
        if (value != null) {
          ref.read(themeControllerProvider.notifier).setThemeMode(value);
          Navigator.pop(context);
        }
      },
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref) {
    final colors = [
      AppColors.purple,
      AppColors.info,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
      const Color(0xFFFF6B9D),
      const Color(0xFF00D9FF),
      const Color(0xFFFFD700),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        title: Text(
          'Выберите цвет',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
          ),
        ),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () {
                ref.read(themeControllerProvider.notifier).setAccentColor(color);
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
