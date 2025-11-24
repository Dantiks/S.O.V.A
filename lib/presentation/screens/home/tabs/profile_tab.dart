import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sova/core/theme/glass_theme.dart';

final themeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);
final accentColorProvider = StateProvider<Color>((ref) => const Color(0xFF7A3DF2));
final usernameProvider = StateProvider<String>((ref) => 'Пользователь');
final biometricProvider = StateProvider<bool>((ref) => false);

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = ref.watch(usernameProvider);
    final biometric = ref.watch(biometricProvider);
    final accentColor = ref.watch(accentColorProvider);

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
                      const Text('Профиль', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5)),
                      const SizedBox(height: 4),
                      Text('Персонализация и настройки', style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.6))),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(24),
                    gradient: GlassTheme.accentGradient,
                    boxShadow: GlassTheme.glowShadow,
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(username, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Premium Member', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
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
                      const Text('Безопасность', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                      const Text('Внешний вид', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
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
                      const Text('Прочее', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          children: [
                            ListTile(leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.notifications, color: Colors.white, size: 22)), title: const Text('Уведомления', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)), subtitle: Text('Настройка уведомлений', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)), trailing: const Icon(Icons.chevron_right, color: Colors.white)),
                            Divider(color: Colors.white.withOpacity(0.1), height: 1),
                            ListTile(leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.download, color: Colors.white, size: 22)), title: const Text('Экспорт данных', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)), subtitle: Text('CSV/PDF экспорт', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)), trailing: const Icon(Icons.chevron_right, color: Colors.white)),
                            Divider(color: Colors.white.withOpacity(0.1), height: 1),
                            ListTile(leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.info, color: Colors.white, size: 22)), title: const Text('О приложении', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)), subtitle: Text('S.O.V.A v2.0.0', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)), trailing: const Icon(Icons.chevron_right, color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
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
