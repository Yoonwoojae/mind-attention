import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/toast_utils.dart';
import '../../core/utils/translation_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      AppLogger.e('Failed to load app version', e);
      setState(() {
        _appVersion = tr('settings_version_unknown');
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('settings_logout_title')),
        content: Text(tr('settings_logout_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('common_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(tr('common_confirm')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await firebase_auth.FirebaseAuth.instance.signOut();
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        AppLogger.e('Logout failed', e);
        ToastUtils.showErrorToast(context, tr('settings_logout_error'));
      }
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('settings_delete_account_title')),
        content: Text(tr('settings_delete_account_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('common_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(tr('settings_delete_account_confirm')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final user = firebase_auth.FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.delete();
          if (mounted) {
            context.go('/login');
          }
        }
      } catch (e) {
        AppLogger.e('Account deletion failed', e);
        ToastUtils.showErrorToast(context, tr('settings_delete_account_error'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings_title')),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildSection(
            title: tr('settings_section_account'),
            children: [
              _buildMenuItem(
                icon: Icons.person_outline,
                title: tr('settings_profile'),
                onTap: () => context.push('/settings/profile'),
              ),
            ],
          ),
          _buildSection(
            title: tr('settings_section_app'),
            children: [
              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: tr('settings_notifications'),
                onTap: () => context.push('/settings/notifications'),
              ),
              _buildMenuItem(
                icon: Icons.language,
                title: tr('settings_language'),
                onTap: () => context.push('/settings/language'),
              ),
            ],
          ),
          _buildSection(
            title: tr('settings_section_info'),
            children: [
              _buildMenuItem(
                icon: Icons.campaign_outlined,
                title: tr('settings_announcements'),
                onTap: () => context.push('/settings/announcements'),
              ),
              _buildMenuItem(
                icon: Icons.info_outline,
                title: tr('settings_version'),
                subtitle: _appVersion,
                onTap: () => context.push('/settings/version'),
              ),
            ],
          ),
          _buildSection(
            title: tr('settings_section_legal'),
            children: [
              _buildMenuItem(
                icon: Icons.description_outlined,
                title: tr('settings_terms'),
                onTap: () => context.push('/settings/terms'),
              ),
              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: tr('settings_privacy'),
                onTap: () => context.push('/settings/privacy'),
              ),
            ],
          ),
          _buildSection(
            title: tr('settings_section_support'),
            children: [
              _buildMenuItem(
                icon: Icons.help_outline,
                title: tr('settings_contact'),
                onTap: () => context.push('/settings/contact'),
              ),
            ],
          ),
          _buildSection(
            title: tr('settings_section_account_management'),
            children: [
              _buildMenuItem(
                icon: Icons.logout,
                title: tr('settings_logout'),
                onTap: _handleLogout,
                textColor: Colors.orange,
              ),
              _buildMenuItem(
                icon: Icons.delete_forever,
                title: tr('settings_delete_account'),
                onTap: _handleDeleteAccount,
                textColor: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}