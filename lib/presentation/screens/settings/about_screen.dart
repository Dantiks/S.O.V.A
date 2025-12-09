import 'package:flutter/material.dart';
import 'package:finer/core/theme/glass_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  'О приложении',
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
                    // Logo & Version
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: GlassTheme.accentGradient,
                              shape: BoxShape.circle,
                              boxShadow: GlassTheme.glowShadow,
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'S.O.V.A',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Smart Optimization & Versatile Analytics',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: GlassTheme.accentGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Версия 2.0.0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Description
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'О приложении',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'S.O.V.A - это ваш персональный финансовый ассистент, который поможет вам контролировать расходы, планировать бюджет и достигать финансовых целей.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Features
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Возможности',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFeature(Icons.account_balance_wallet, 'Управление счетами', 'Все банковские счета в одном месте'),
                          _buildFeature(Icons.receipt_long, 'Транзакции', 'Отслеживание доходов и расходов'),
                          _buildFeature(Icons.analytics, 'Аналитика', 'Детальный анализ ваших финансов'),
                          _buildFeature(Icons.flag, 'Цели накоплений', 'Создавайте и отслеживайте финансовые цели'),
                          _buildFeature(Icons.repeat, 'Регулярные платежи', 'Автоматические напоминания о платежах'),
                          _buildFeature(Icons.smart_toy, 'AI Помощник', 'Умные рекомендации и советы'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Legal
                    GlassCard(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.policy, color: Colors.white, size: 22),
                            ),
                            title: const Text(
                              'Политика конфиденциальности',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white),
                            onTap: () => _launchURL('https://example.com/privacy'),
                          ),
                          Divider(color: Colors.white.withOpacity(0.1), height: 1),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.description, color: Colors.white, size: 22),
                            ),
                            title: const Text(
                              'Условия использования',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white),
                            onTap: () => _launchURL('https://example.com/terms'),
                          ),
                          Divider(color: Colors.white.withOpacity(0.1), height: 1),
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.code, color: Colors.white, size: 22),
                            ),
                            title: const Text(
                              'Лицензии Open Source',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            trailing: const Icon(Icons.chevron_right, color: Colors.white),
                            onTap: () => showLicensePage(
                              context: context,
                              applicationName: 'S.O.V.A',
                              applicationVersion: '2.0.0',
                              applicationIcon: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: GlassTheme.accentGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Contact
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Контакты',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildContactItem(Icons.email, 'Email', 'support@sova.app'),
                          const SizedBox(height: 12),
                          _buildContactItem(Icons.language, 'Website', 'www.sova.app'),
                          const SizedBox(height: 12),
                          _buildContactItem(Icons.bug_report, 'Report a bug', 'bugs@sova.app'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Copyright
                    Center(
                      child: Text(
                        '© 2024 S.O.V.A\nAll rights reserved',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF7A3DF2).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF7A3DF2), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF7A3DF2), size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
