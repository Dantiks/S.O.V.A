import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finer/presentation/providers/auth_provider.dart';
import 'package:finer/presentation/screens/pin/change_pin_screen.dart';
import 'package:finer/presentation/screens/settings/about_screen.dart';
import 'package:finer/presentation/screens/settings/notification_settings_screen.dart';
import 'package:finer/presentation/screens/settings/export_data_screen.dart';
import 'package:finer/presentation/screens/settings/settings_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
final accentColorProvider = StateProvider<Color>((ref) => const Color(0xFF7A3DF2));
final usernameProvider = StateProvider<String>((ref) => 'Пользователь');
final biometricProvider = StateProvider<bool>((ref) => false);
final avatarProvider = StateProvider<String?>((ref) => null);

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);
    final biometric = ref.watch(biometricProvider);
    final accentColor = ref.watch(accentColorProvider);
    final avatarPath = ref.watch(avatarProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)])),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Профиль', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5))
                          .animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 4),
                      Text('Персонализация и настройки', style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.6)))
                          .animate(delay: 100.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(28),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7A3DF2), Color(0xFF5A2DB2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7A3DF2).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
                            if (image != null) {
                              ref.read(avatarProvider.notifier).state = image.path;
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  image: avatarPath != null
                                      ? DecorationImage(image: FileImage(File(avatarPath)), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: avatarPath == null ? const Icon(Icons.person, color: Colors.white, size: 45) : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7A3DF2),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: const Color(0xFF7A3DF2).withOpacity(0.5), blurRadius: 8)],
                                  ),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Premium',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            final controller = TextEditingController(text: username);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1a1a2e),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                title: const Text('Изменить имя', style: TextStyle(color: Colors.white)),
                                content: TextField(
                                  controller: controller,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    labelText: 'Имя',
                                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.3))),
                                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF7A3DF2), width: 2)),
                                  ),
                                ),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
                                  TextButton(
                                    onPressed: () {
                                      if (controller.text.isNotEmpty) {
                                        ref.read(usernameProvider.notifier).state = controller.text;
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Сохранить', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0).shimmer(delay: 1000.ms, duration: 2000.ms),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.security, color: Color(0xFF7A3DF2), size: 24),
                          const SizedBox(width: 8),
                          const Text('Безопасность', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.fingerprint, color: Colors.white, size: 22)),
                              title: const Text('Face ID / Touch ID', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                              subtitle: Text('Биометрическая аутентификация', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                              trailing: Switch(value: biometric, onChanged: (v) => ref.read(biometricProvider.notifier).state = v, activeColor: accentColor),
                            ),
                            Divider(color: Colors.white.withOpacity(0.1), height: 1),
                            ListTile(
                              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.lock, color: Colors.white, size: 22)),
                              title: const Text('Изменить PIN', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                              subtitle: Text('Сменить PIN-код', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePinScreen()));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.palette, color: Color(0xFF7A3DF2), size: 24),
                          const SizedBox(width: 8),
                          const Text('Внешний вид', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.brightness_6, color: Colors.white, size: 22)),
                              title: const Text('Тема', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                              subtitle: Text('Тёмная', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white),
                            ),
                            Divider(color: Colors.white.withOpacity(0.1), height: 1),
                            ListTile(
                              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.palette, color: Colors.white, size: 22)),
                              title: const Text('Акцентный цвет', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                              subtitle: Text('Фиолетовый', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 24, height: 24, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.chevron_right, color: Colors.white),
                                ],
                              ),
                              onTap: () {
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
                                        _ColorOption(color: const Color(0xFF7A3DF2), label: 'Фиолетовый', onTap: () { ref.read(accentColorProvider.notifier).state = const Color(0xFF7A3DF2); Navigator.pop(context); }),
                                        _ColorOption(color: const Color(0xFF4CAF50), label: 'Зелёный', onTap: () { ref.read(accentColorProvider.notifier).state = const Color(0xFF4CAF50); Navigator.pop(context); }),
                                        _ColorOption(color: const Color(0xFFE91E63), label: 'Розовый', onTap: () { ref.read(accentColorProvider.notifier).state = const Color(0xFFE91E63); Navigator.pop(context); }),
                                        _ColorOption(color: const Color(0xFF2196F3), label: 'Синий', onTap: () { ref.read(accentColorProvider.notifier).state = const Color(0xFF2196F3); Navigator.pop(context); }),
                                        _ColorOption(color: const Color(0xFFFF9800), label: 'Оранжевый', onTap: () { ref.read(accentColorProvider.notifier).state = const Color(0xFFFF9800); Navigator.pop(context); }),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.devices, color: Color(0xFF7A3DF2), size: 24),
                          const SizedBox(width: 8),
                          const Text('Активность устройства', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 12),
                      GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Последний вход', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                                    const SizedBox(height: 4),
                                    Text(DateTime.now().toString().substring(0, 16), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.check_circle, color: Colors.green, size: 24),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Divider(color: Colors.white.withOpacity(0.1)),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _DeviceInfoTile(label: 'Устройство', value: 'iPhone', icon: Icons.phone_iphone),
                                ),
                                Expanded(
                                  child: _DeviceInfoTile(label: 'Сессий', value: '1', icon: Icons.devices),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.settings, color: Color(0xFF7A3DF2), size: 24),
                          const SizedBox(width: 8),
                          const Text('Быстрый доступ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ).animate(delay: 600.ms).fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF7A3DF2), Color(0xFF5A2DB2)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF7A3DF2).withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.settings, color: Colors.white, size: 24),
                              ),
                              title: const Text(
                                'Настройки',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Настройка приложения',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                );
                              },
                            ),
                            Divider(color: Colors.white.withOpacity(0.1), height: 1),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.shield, color: Colors.green, size: 24),
                              ),
                              title: const Text('Безопасность', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                              subtitle: Text('PIN и биометрия', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white),
                              onTap: () {
                                // Scroll to security section or navigate
                              },
                            ),
                            Divider(color: Colors.white.withOpacity(0.1), height: 1),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.help_outline, color: Colors.orange, size: 24),
                              ),
                              title: const Text('Помощь', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                              subtitle: Text('FAQ и поддержка', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white),
                              onTap: () {
                                // TODO: Open help screen
                              },
                            ),
                            Divider(color: Colors.white.withOpacity(0.1), height: 1),
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.info, color: Colors.blue, size: 24),
                              ),
                              title: const Text('О приложении', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                              subtitle: Text('FINER v1.0.0', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
                              trailing: const Icon(Icons.chevron_right, color: Colors.white),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Consumer(
                    builder: (context, ref, _) {
                      return WaterRippleButton(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF1a1a2e),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Text('Выйти из аккаунта?', style: TextStyle(color: Colors.white)),
                              content: const Text('Вы уверены, что хотите выйти?', style: TextStyle(color: Colors.white70)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Отмена'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Выйти', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await ref.read(authControllerProvider.notifier).signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                            }
                          }
                        },
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        gradient: const LinearGradient(colors: [Colors.red, Color(0xFFC62828)]),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Выйти из аккаунта', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ColorOption({required this.color, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2)]),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}

class _DeviceInfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DeviceInfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF7A3DF2), size: 24),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
