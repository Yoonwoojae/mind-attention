import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_attention/core/constants/app_colors.dart';
import 'package:mind_attention/core/utils/translation_utils.dart';

class UserCustomizationScreen extends StatefulWidget {
  const UserCustomizationScreen({super.key});

  @override
  State<UserCustomizationScreen> createState() => _UserCustomizationScreenState();
}

class _UserCustomizationScreenState extends State<UserCustomizationScreen> {
  String? _selectedGoal;
  String? _selectedLevel;
  String? _selectedDuration;

  final List<Map<String, dynamic>> _goals = [
    {'id': 'stress', 'title': 'goal_stress', 'icon': Icons.self_improvement},
    {'id': 'focus', 'title': 'goal_focus', 'icon': Icons.psychology},
    {'id': 'emotion', 'title': 'goal_emotion', 'icon': Icons.favorite},
    {'id': 'sleep', 'title': 'goal_sleep', 'icon': Icons.bedtime},
  ];

  final List<Map<String, dynamic>> _levels = [
    {'id': 'beginner', 'title': 'level_beginner', 'subtitle': 'level_beginner_desc'},
    {'id': 'intermediate', 'title': 'level_intermediate', 'subtitle': 'level_intermediate_desc'},
    {'id': 'advanced', 'title': 'level_advanced', 'subtitle': 'level_advanced_desc'},
  ];

  final List<Map<String, dynamic>> _durations = [
    {'id': 'short', 'title': 'duration_short', 'subtitle': 'duration_short_time'},
    {'id': 'long', 'title': 'duration_long', 'subtitle': 'duration_long_time'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 프로그레스 바
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: _selectedGoal != null ? AppColors.primary : Colors.grey[200],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: _selectedLevel != null ? AppColors.primary : Colors.grey[200],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: _selectedDuration != null ? AppColors.primary : Colors.grey[200],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        tr('customization_title'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tr('customization_subtitle'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 목표 선택
                      Text(
                        tr('customization_goal_title'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: _goals.length,
                        itemBuilder: (context, index) {
                          final goal = _goals[index];
                          final isSelected = _selectedGoal == goal['id'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGoal = goal['id'];
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey[200]!,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    goal['icon'],
                                    size: 32,
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey[600],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tr(goal['title']),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      // 경험 수준
                      Text(
                        tr('customization_level_title'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_levels.length, (index) {
                        final level = _levels[index];
                        final isSelected = _selectedLevel == level['id'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedLevel = level['id'];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey[200]!,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Container(
                                          margin: const EdgeInsets.all(4),
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tr(level['title']),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        tr(level['subtitle']),
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
                      // 선호 스타일
                      Text(
                        tr('customization_duration_title'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: List.generate(_durations.length, (index) {
                          final duration = _durations[index];
                          final isSelected = _selectedDuration == duration['id'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDuration = duration['id'];
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: index == 0 ? 6 : 0,
                                  left: index == 1 ? 6 : 0,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey[200]!,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      duration['id'] == 'short'
                                          ? Icons.timer
                                          : Icons.hourglass_full,
                                      size: 32,
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.grey[600],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      tr(duration['title']),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tr(duration['subtitle']),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 다음 버튼
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedGoal != null &&
                          _selectedLevel != null &&
                          _selectedDuration != null
                      ? () {
                          context.go('/roadmap');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    tr('continue'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}