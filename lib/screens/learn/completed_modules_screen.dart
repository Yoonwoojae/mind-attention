import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mind_attention/core/utils/logger.dart';
import 'package:mind_attention/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class CompletedModulesScreen extends StatelessWidget {
  const CompletedModulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 샘플 데이터 - 실제로는 데이터베이스에서 가져옴
    final completedModules = [
      {
        'title': 'learn_module_breathing_title'.tr(),
        'completedDate': '2024.01.15',
        'icon': Icons.air,
        'duration': '10 min',
        'sessions': 6,
      },
      {
        'title': 'learn_module_sleep_title'.tr(),
        'completedDate': '2024.01.10',
        'icon': Icons.nightlight_round,
        'duration': '15 min',
        'sessions': 8,
      },
      {
        'title': 'learn_module_emotion_title'.tr(),
        'completedDate': '2024.01.05',
        'icon': Icons.favorite,
        'duration': '10 min',
        'sessions': 5,
      },
      {
        'title': 'learn_module_mindfulness_title'.tr(),
        'completedDate': '2023.12.28',
        'icon': Icons.self_improvement,
        'duration': '20 min',
        'sessions': 10,
      },
      {
        'title': 'learn_module_stress_title'.tr(),
        'completedDate': '2023.12.20',
        'icon': Icons.spa,
        'duration': '12 min',
        'sessions': 7,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          'learn_completed_modules_title'.tr(),
          style: const TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Color(0xFF2D3436)),
            onSelected: (value) {
              AppLogger.i('Sort by: $value');
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'recent',
                child: Text('learn_sort_recent'.tr()),
              ),
              PopupMenuItem(
                value: 'oldest',
                child: Text('learn_sort_oldest'.tr()),
              ),
              PopupMenuItem(
                value: 'name',
                child: Text('learn_sort_name'.tr()),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${completedModules.length} ' + 'learn_modules_completed'.tr(),
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: completedModules.length,
              itemBuilder: (context, index) {
                final module = completedModules[index];
                return _buildCompletedModuleItem(
                  context: context,
                  title: module['title'] as String,
                  completedDate: module['completedDate'] as String,
                  icon: module['icon'] as IconData,
                  duration: module['duration'] as String,
                  sessions: module['sessions'] as int,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedModuleItem({
    required BuildContext context,
    required String title,
    required String completedDate,
    required IconData icon,
    required String duration,
    required int sessions,
  }) {
    return GestureDetector(
      onTap: () {
        AppLogger.i('Opening completed module in review mode: $title');
        context.push('/module/review', extra: {'title': title, 'mode': 'review'});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.green,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        completedDate,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.timer,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        duration,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$sessions ' + 'learn_sessions'.tr(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'learn_review_available'.tr(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}