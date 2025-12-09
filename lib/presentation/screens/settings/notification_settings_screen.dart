import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finer/core/services/notification_service.dart';

// Providers для настроек уведомлений
final transactionNotificationsProvider = StateProvider<bool>((ref) => true);
final goalNotificationsProvider = StateProvider<bool>((ref) => true);
final recurringNotificationsProvider = StateProvider<bool>((ref) => true);
final budgetNotificationsProvider = StateProvider<bool>((ref) => true);
final dailySummaryProvider = StateProvider<bool>((ref) => false);
final weeklySummaryProvider = StateProvider<bool>((ref) => true);
final soundProvider = StateProvider<bool>((ref) => true);
final vibrationProvider = StateProvider<bool>((ref) => true);

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    ref.read(transactionNotificationsProvider.notifier).state = prefs.getBool('notif_transactions') ?? true;
    ref.read(goalNotificationsProvider.notifier).state = prefs.getBool('notif_goals') ?? true;
    ref.read(recurringNotificationsProvider.notifier).state = prefs.getBool('notif_recurring') ?? true;
    ref.read(budgetNotificationsProvider.notifier).state = prefs.getBool('notif_budget') ?? true;
    ref.read(dailySummaryProvider.notifier).state = prefs.getBool('notif_daily_summary') ?? false;
    ref.read(weeklySummaryProvider.notifier).state = prefs.getBool('notif_weekly_summary') ?? true;
    ref.read(soundProvider.notifier).state = prefs.getBool('notif_sound') ?? true;
    ref.read(vibrationProvider.notifier).state = prefs.getBool('notif_vibration') ?? true;
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final transactionNotif = ref.watch(transactionNotificationsProvider);
    final goalNotif = ref.watch(goalNotificationsProvider);
    final recurringNotif = ref.watch(recurringNotificationsProvider);
    final budgetNotif = ref.watch(budgetNotificationsProvider);
    final dailySummary = ref.watch(dailySummaryProvider);
    final weeklySummary = ref.watch(weeklySummaryProvider);
    final sound = ref.watch(soundProvider);
    final vibration = ref.watch(vibrationProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF0f0f1e)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text(
                  'Настройки уведомлений',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Типы уведомлений
                    _buildSectionTitle('Типы уведомлений'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            icon: Icons.receipt_long,
                            title: 'Транзакции',
                            subtitle: 'Уведомления о новых транзакциях',
                            value: transactionNotif,
                            onChanged: (val) {
                              ref.read(transactionNotificationsProvider.notifier).state = val;
                              _saveSetting('notif_transactions', val);
                            },
                          ),
                          Divider(color: Colors.white.withOpacity(0.1), height: 1),
                          _buildSwitchTile(
                            icon: Icons.flag,
                            title: 'Цели накоплений',
                            subtitle: 'Прогресс и достижение целей',
                            value: goalNotif,
                            onChanged: (val) {
                              ref.read(goalNotificationsProvider.notifier).state = val;
                              _saveSetting('notif_goals', val);
                            },
                          ),
                          Divider(color: Colors.white.withOpacity(0.1), height: 1),
                          _buildSwitchTile(
                            icon: Icons.repeat,
                            title: 'Регулярные платежи',
                            subtitle: 'Напоминания о предстоящих платежах',
                            value: recurringNotif,
                            onChanged: (val) {
                              ref.read(recurringNotificationsProvider.notifier).state = val;
                              _saveSetting('notif_recurring', val);
                            },
                          ),
                          Divider(color: Colors.white.withOpacity(0.1), height: 1),
                          _buildSwitchTile(
                            icon: Icons.account_balance_wallet,
                            title: 'Бюджет',
                            subtitle: 'Превышение лимитов бюджета',
                            value: budgetNotif,
                            onChanged: (val) {
                              ref.read(budgetNotificationsProvider.notifier).state = val;
                              _saveSetting('notif_budget', val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Сводки
                    _buildSectionTitle('Сводки'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            icon: Icons.today,
                            title: 'Ежедневная сводка',
                            subtitle: 'Итоги дня каждый вечер',
                            value: dailySummary,
                            onChanged: (val) {
                              ref.read(dailySummaryProvider.notifier).state = val;
                              _saveSetting('notif_daily_summary', val);
                            },
                          ),
                          Divider(color: Colors.white.withOpacity(0.1), height: 1),
                          _buildSwitchTile(
                            icon: Icons.calendar_today,
                            title: 'Еженедельная сводка',
                            subtitle: 'Итоги недели каждый понедельник',
                            value: weeklySummary,
                            onChanged: (val) {
                              ref.read(weeklySummaryProvider.notifier).state = val;
                              _saveSetting('notif_weekly_summary', val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Звук и вибрация
                    _buildSectionTitle('Звук и вибрация'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            icon: Icons.volume_up,
                            title: 'Звук',
                            subtitle: 'Звуковой сигнал уведомлений',
                            value: sound,
                            onChanged: (val) {
                              ref.read(soundProvider.notifier).state = val;
                              _saveSetting('notif_sound', val);
                            },
                          ),
                          Divider(color: Colors.white.withOpacity(0.1), height: 1),
                          _buildSwitchTile(
                            icon: Icons.vibration,
                            title: 'Вибрация',
                            subtitle: 'Вибрация при уведомлениях',
                            value: vibration,
                            onChanged: (val) {
                              ref.read(vibrationProvider.notifier).state = val;
                              _saveSetting('notif_vibration', val);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Тестирование уведомлений
                    _buildSectionTitle('Тестирование'),
                    const SizedBox(height: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notifications_active,
                                color: Colors.white.withOpacity(0.7),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Проверить уведомления',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final notificationService = NotificationService();
                                await notificationService.showLocalNotification(
                                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                                  title: '🦉 S.O.V.A',
                                  body: 'Уведомления работают отлично! 🎉',
                                  channelId: 'default_channel',
                                );
                                
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Тестовое уведомление отправлено!'),
                                      backgroundColor: Color(0xFF7A3DF2),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.send),
                              label: const Text('Отправить тестовое уведомление'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7A3DF2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final notificationService = NotificationService();
                                final token = await notificationService.getToken();
                                
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFF1A1A1A),
                                      title: const Text(
                                        'FCM Token',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      content: SelectableText(
                                        token ?? 'Token не получен',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Закрыть'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.vpn_key),
                              label: const Text('Показать FCM Token'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Системные настройки
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Дополнительные настройки доступны в системных настройках приложения',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF7A3DF2),
      ),
    );
  }
}
