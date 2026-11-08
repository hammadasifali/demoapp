import 'package:flutter/material.dart';
import '../api_service.dart';
import '../app_settings.dart';
import 'login_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const Map<String, Map<String, String>> translations = {
    'en': {
      'title': 'Settings',
      'appearance': 'Appearance',
      'theme': 'App Theme',
      'light': 'Light Mode',
      'dark': 'Dark Mode',
      'language': 'Language',
      'english': 'English',
      'urdu': 'Urdu',
      'account': 'Account',
      'profile': 'Profile',
      'notifications': 'Notifications',
      'other': 'Other Settings',
      'logout': 'Logout',
      'logout_message': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      'confirm': 'Logout',
      'theme_desc': 'Choose your preferred appearance',
      'language_desc': 'Select your preferred language',
      'profile_desc': 'Manage your personal information',
      'notification_desc': 'Manage plant care reminders',
    },
    'ur': {
      'title': 'ترتیبات',
      'appearance': 'ظاہری شکل',
      'theme': 'ایپ تھیم',
      'light': 'لائٹ موڈ',
      'dark': 'ڈارک موڈ',
      'language': 'زبان',
      'english': 'انگریزی',
      'urdu': 'اردو',
      'account': 'اکاؤنٹ',
      'profile': 'پروفائل',
      'notifications': 'اطلاعات',
      'other': 'دیگر ترتیبات',
      'logout': 'لاگ آؤٹ',
      'logout_message': 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟',
      'cancel': 'منسوخ کریں',
      'confirm': 'لاگ آؤٹ',
      'theme_desc': 'اپنی پسند کا تھیم منتخب کریں',
      'language_desc': 'اپنی پسند کی زبان منتخب کریں',
      'profile_desc': 'اپنی ذاتی معلومات دیکھیں',
      'notification_desc': 'پودوں کی دیکھ بھال کی یاد دہانیاں',
    },
  };

  String t(String key) {
    final language = AppSettings.locale.value.languageCode;
    return translations[language]?[key] ?? translations['en']![key]!;
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t('logout')),
        content: Text(t('logout_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t('cancel')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t('confirm')),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await ApiService.logout();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to logout. Please try again.')),
      );
    }
  }

  Widget _sectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 24, 5, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _settingsCard({required Widget child, required BuildContext context}) {
    return Card(margin: EdgeInsets.zero, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppSettings.themeMode,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<Locale>(
          valueListenable: AppSettings.locale,
          builder: (context, locale, _) {
            final isDark = themeMode == ThemeMode.dark;
            final isUrdu = locale.languageCode == 'ur';

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
              children: [
                // Header
                Row(
                  children: [
                    const Icon(
                      Icons.eco,
                      size: 30,
                      color: AppSettings.leafGreen,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      t('title'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                // Appearance
                _sectionTitle(t('appearance'), context),

                _settingsCard(
                  context: context,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.palette_outlined),
                        title: Text(t('theme')),
                        subtitle: Text(t('theme_desc')),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _themeOption(
                                context,
                                title: t('light'),
                                icon: Icons.light_mode,
                                selected: !isDark,
                                onTap: () {
                                  AppSettings.setTheme(ThemeMode.light);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _themeOption(
                                context,
                                title: t('dark'),
                                icon: Icons.dark_mode,
                                selected: isDark,
                                onTap: () {
                                  AppSettings.setTheme(ThemeMode.dark);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(t('language')),
                        subtitle: Text(t('language_desc')),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 0, 15, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _languageOption(
                                title: 'English',
                                selected: !isUrdu,
                                onTap: () {
                                  AppSettings.setLanguage('en');
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _languageOption(
                                title: 'اردو',
                                selected: isUrdu,
                                onTap: () {
                                  AppSettings.setLanguage('ur');
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Account
                _sectionTitle(t('account'), context),

                _settingsCard(
                  context: context,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.person_outline),
                        title: Text(t('profile')),
                        subtitle: Text(t('profile_desc')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile page coming soon'),
                            ),
                          );
                        },
                      ),

                      const Divider(height: 1),

                      ListTile(
                        leading: const Icon(Icons.notifications_outlined),
                        title: Text(t('notifications')),
                        subtitle: Text(t('notification_desc')),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notification settings coming soon',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Other settings
                _sectionTitle(t('other'), context),

                _settingsCard(
                  context: context,
                  child: ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: Colors.red,
                    ),
                    title: Text(
                      t('logout'),
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _logout(context),
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.spa,
                        size: 35,
                        color: AppSettings.leafGreen,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Grow Green 🌱',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppSettings.leafGreen,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isUrdu
                            ? 'اپنے پودوں کا خیال رکھیں'
                            : 'Take care of your plants.',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Theme.of(context).hintColor,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _themeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _languageOption({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: selected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
