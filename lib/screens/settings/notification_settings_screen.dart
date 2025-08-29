import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/toast_utils.dart';
import '../../core/utils/translation_utils.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushEnabled = false;
  bool _learningReminder = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() => _isLoading = true);
    try {
      final status = await Permission.notification.status;
      setState(() {
        _pushEnabled = status.isGranted;
      });

      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final supabase = Supabase.instance.client;
        final response = await supabase
            .schema('mind_attention_play')
            .from('user_notification_settings')
            .select()
            .eq('user_id', user.uid)
            .maybeSingle();

        if (response != null) {
          setState(() {
            _learningReminder = response['learning_reminder'] ?? false;
            if (response['reminder_time'] != null) {
              final parts = response['reminder_time'].split(':');
              _reminderTime = TimeOfDay(
                hour: int.parse(parts[0]),
                minute: int.parse(parts[1]),
              );
            }
          });
        }
      }
    } catch (e) {
      AppLogger.e('Failed to load notification settings', e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePushNotifications(bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        setState(() => _pushEnabled = true);
        await FirebaseMessaging.instance.requestPermission();
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _updateFCMToken(token);
        }
        ToastUtils.showSuccessToast(context, tr('notifications_enabled'));
      } else {
        ToastUtils.showErrorToast(context, tr('notifications_permission_denied'));
      }
    } else {
      setState(() => _pushEnabled = false);
      await _removeFCMToken();
      ToastUtils.showInfoToast(context, tr('notifications_disabled'));
    }
  }

  Future<void> _updateFCMToken(String token) async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final supabase = Supabase.instance.client;
        await supabase.schema('mind_attention_play').from('user_devices').upsert({
          'user_id': user.uid,
          'fcm_token': token,
          'device_type': 'mobile',
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      AppLogger.e('Failed to update FCM token', e);
    }
  }

  Future<void> _removeFCMToken() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final supabase = Supabase.instance.client;
        await supabase
            .schema('mind_attention_play')
            .from('user_devices')
            .delete()
            .eq('user_id', user.uid);
      }
    } catch (e) {
      AppLogger.e('Failed to remove FCM token', e);
    }
  }

  Future<void> _updateLearningReminder(bool value) async {
    setState(() => _learningReminder = value);
    await _saveNotificationSettings();
    ToastUtils.showSuccessToast(
      context,
      value ? tr('learning_reminder_enabled') : tr('learning_reminder_disabled'),
    );
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
      await _saveNotificationSettings();
      ToastUtils.showSuccessToast(context, tr('reminder_time_updated'));
    }
  }

  Future<void> _saveNotificationSettings() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final supabase = Supabase.instance.client;
        await supabase.schema('mind_attention_play').from('user_notification_settings').upsert({
          'user_id': user.uid,
          'learning_reminder': _learningReminder,
          'reminder_time': '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      AppLogger.e('Failed to save notification settings', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings_notifications')),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSection(
                  title: tr('notifications_general'),
                  children: [
                    SwitchListTile(
                      title: Text(tr('notifications_push')),
                      subtitle: Text(tr('notifications_push_desc')),
                      value: _pushEnabled,
                      onChanged: _togglePushNotifications,
                    ),
                  ],
                ),
                _buildSection(
                  title: tr('notifications_learning'),
                  children: [
                    SwitchListTile(
                      title: Text(tr('notifications_learning_reminder')),
                      subtitle: Text(tr('notifications_learning_reminder_desc')),
                      value: _learningReminder,
                      onChanged: _pushEnabled ? _updateLearningReminder : null,
                    ),
                    ListTile(
                      enabled: _learningReminder && _pushEnabled,
                      title: Text(tr('notifications_reminder_time')),
                      subtitle: Text(_reminderTime.format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: _learningReminder && _pushEnabled ? _selectReminderTime : null,
                    ),
                  ],
                ),
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
}