import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _morningNotification = true;
  bool _afternoonNotification = false;
  bool _eveningNotification = true;
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _afternoonTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 20, minute: 0);

  Future<void> _selectTime(BuildContext context, TimeOfDay currentTime, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (picked != null && picked != currentTime) {
      setState(() {
        onTimeSelected(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'notification_settings_title'.tr(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'notification_settings_subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // 알림 설정 리스트
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  // 아침 알림
                  _buildNotificationCard(
                    title: 'notification_morning_title'.tr(),
                    subtitle: 'notification_morning_subtitle'.tr(),
                    icon: Icons.wb_sunny,
                    iconColor: Colors.orange,
                    isEnabled: _morningNotification,
                    time: _morningTime,
                    onToggle: (value) {
                      setState(() {
                        _morningNotification = value;
                      });
                    },
                    onTimeSelect: () {
                      _selectTime(context, _morningTime, (time) {
                        _morningTime = time;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // 오후 알림
                  _buildNotificationCard(
                    title: 'notification_afternoon_title'.tr(),
                    subtitle: 'notification_afternoon_subtitle'.tr(),
                    icon: Icons.wb_cloudy,
                    iconColor: Colors.blue,
                    isEnabled: _afternoonNotification,
                    time: _afternoonTime,
                    onToggle: (value) {
                      setState(() {
                        _afternoonNotification = value;
                      });
                    },
                    onTimeSelect: () {
                      _selectTime(context, _afternoonTime, (time) {
                        _afternoonTime = time;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // 저녁 알림
                  _buildNotificationCard(
                    title: 'notification_evening_title'.tr(),
                    subtitle: 'notification_evening_subtitle'.tr(),
                    icon: Icons.nightlight_round,
                    iconColor: Colors.indigo,
                    isEnabled: _eveningNotification,
                    time: _eveningTime,
                    onToggle: (value) {
                      setState(() {
                        _eveningNotification = value;
                      });
                    },
                    onTimeSelect: () {
                      _selectTime(context, _eveningTime, (time) {
                        _eveningTime = time;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  // 알림 설명
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'notification_info'.tr(),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 버튼들
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Not now 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        context.go('/app-benefits');
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'not_now'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 다음 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/app-benefits');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B73FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'notification_settings_continue'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isEnabled,
    required TimeOfDay time,
    required Function(bool) onToggle,
    required VoidCallback onTimeSelect,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isEnabled ? iconColor.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled ? iconColor.withOpacity(0.3) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isEnabled ? iconColor.withOpacity(0.2) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isEnabled ? iconColor : Colors.grey[400],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isEnabled ? Colors.black87 : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: isEnabled ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeColor: iconColor,
              ),
            ],
          ),
          if (isEnabled) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onTimeSelect,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: iconColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time.format(context),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}