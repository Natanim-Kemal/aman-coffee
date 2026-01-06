import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/custom_header.dart';
import 'profile_edit_screen.dart';
import 'notification_settings_screen.dart';
import 'business_settings_screen.dart';
import 'data_management_screen.dart';
import 'about_screen.dart';
import '../audit/audit_log_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  localizations.settings,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.manageYourAccount,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                _buildSectionHeader(theme, 'Business'),
                _buildSettingsTile(
                  context,
                  icon: Icons.store,
                  title: 'Business Information',
                  subtitle: settingsProvider.companyName,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BusinessSettingsScreen()),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'General'),
                _buildSettingsTile(
                  context,
                  icon: Icons.person_outline,
                  title: localizations.profile,
                  subtitle: localizations.manageYourAccount,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileEditScreen()),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: localizations.notifications,
                  subtitle: localizations.customizeAlerts,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
                    );
                  },
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
                
                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'Preferences'),
                 _buildSettingsTile(
                  context,
                  icon: Icons.dark_mode_outlined,
                  title: localizations.darkMode,
                  subtitle: localizations.systemDefault, 
                  trailing: Switch(
                    value: isDark, 
                    onChanged: (val) => themeProvider.toggleTheme(val), 
                    activeColor: AppColors.primary
                  ),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.language,
                  title: localizations.changeLanguage,
                  subtitle: settingsProvider.locale.languageCode == 'am' ? 'Amharic (አማርኛ)' : 'English',
                  onTap: () => _showLanguageBottomSheet(context),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'Security'),
                _buildSettingsTile(
                  context,
                  icon: Icons.lock_outline,
                  title: localizations.changePassword,
                  onTap: () => _showChangePasswordDialog(context),
                ),
                 _buildSettingsTile(
                  context,
                  icon: Icons.security,
                  title: localizations.twoFactorAuth,
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),

                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'Data'),
                _buildSettingsTile(
                  context,
                  icon: Icons.backup_outlined,
                  title: 'Data Management',
                  subtitle: 'Backup, Export, Clear Cache',
                   onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DataManagementScreen()),
                    );
                  },
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),
                
                // Audit Logs - Admin only
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    if (authProvider.userRole?.canManageUsers != true) {
                      return const SizedBox.shrink();
                    }
                    return _buildSettingsTile(
                      context,
                      icon: Icons.history,
                      title: 'Audit Logs',
                      subtitle: 'View system activity logs',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AuditLogScreen()),
                        );
                      },
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                _buildSectionHeader(theme, 'App'),
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About Cofiz',
                  subtitle: 'Version 1.0.0',
                   onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutScreen()),
                    );
                  },
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                ),

                const SizedBox(height: 32),
                TextButton(
                  onPressed: () async {
                    // Show confirmation dialog
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(localizations.signOut),
                        content: Text(localizations.areYouSureSignOut),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(localizations.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(localizations.signOut, style: const TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true && context.mounted) {
                      await Provider.of<AuthProvider>(context, listen: false).signOut();
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  child: Text(localizations.signOut),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.textMutedDark,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    // ... same implementation ...
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title, 
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: AppColors.textMutedDark, fontSize: 12)) : null,
        trailing: trailing,
      ),
    );
  }

  // ... helper methods (language bottom sheet, change password) ...
  // Coping logic from previous file or rewriting
  
  void _showChangePasswordDialog(BuildContext context) {
    // ...
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'), // String literal for now? Or localize 'Change Password' (done)
        content: const Text(
          'To change your password, we will send a password reset link to your email address. Do you want to proceed?'
        ), // Should localize this too, but for now literal is okay if not in ARB
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final email = authProvider.user?.email;
              
              if (email != null) {
                final success = await authProvider.resetPassword(email: email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success 
                        ? 'Password reset email sent to $email' 
                        : 'Failed to send reset email: ${authProvider.errorMessage}'
                      ),
                    ),
                  );
                }
              }
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                 AppLocalizations.of(context)?.selectLanguage ?? 'Select Language',
                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
               ),
               const SizedBox(height: 16),
               _buildLanguageOption(context, 'English', const Locale('en')),
               _buildLanguageOption(context, 'Amharic (አማርኛ)', const Locale('am')),
            ],
          ),
        );
      }
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, Locale locale) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isSelected = settings.locale.languageCode == locale.languageCode;
    
    return ListTile(
      title: Text(name),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        settings.setLocale(locale);
        Navigator.pop(context);
      },
    );
  }
}