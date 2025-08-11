import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_attention/core/utils/logger.dart';
import 'package:mind_attention/core/constants/app_colors.dart';
import 'package:mind_attention/screens/learn/learn_screen.dart';
import 'package:mind_attention/screens/focus/focus_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // 임시 데이터 - 실제로는 서비스에서 관리
  int currentChapter = 3;
  int totalChapters = 8;
  String currentModuleName = "Raising low self-esteem";
  double sessionProgress = 0.25; // 현재 세션 진행률 (0%, 25%, 50%, 75%, 100%)
  
  // Today's exercises 데이터
  List<Map<String, dynamic>> completedExercises = [
    {
      'title': 'Understanding self-esteem',
      'type': 'lesson',
      'duration': '5 min',
      'isCompleted': true,
    },
    {
      'title': 'Reflection exercise',
      'type': 'exercise',
      'duration': '3 min',
      'isCompleted': true,
    },
  ];
  
  Map<String, dynamic>? currentExercise = {
    'title': 'Building confidence',
    'type': 'lesson',
    'duration': '7 min',
    'isCompleted': false,
  };
  
  // Weekly goal 데이터
  int? weeklyGoal;
  List<bool> weeklyProgress = [true, true, false, false, false, false, false];
  
  // Daily focus 데이터
  String? dailyFocus;
  TimeOfDay? startReminder;
  TimeOfDay? endReminder;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomePage(),
      const LearnScreen(),
      const FocusScreen(),
    ];
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(context),
    );
  }
  
  Widget _buildHomePage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'home_title'.tr(),
          style: const TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF2D3436)),
            onPressed: () {
              AppLogger.i('Settings tapped - navigating to profile');
              context.push('/profile');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentModuleProgress(),
            const SizedBox(height: 20),
            _buildTodaysExercises(),
            const SizedBox(height: 20),
            _buildWeeklyLearningGoal(),
            const SizedBox(height: 20),
            _buildDailyFocus(),
          ],
        ),
      ),
    );
  }

  // 1. 현재 모듈 진행상황
  Widget _buildCurrentModuleProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.9), AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You're on chapter $currentChapter of $totalChapters",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentModuleName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // 세션 진행률 표시
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session progress: ${(sessionProgress * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: sessionProgress,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  AppLogger.i('Continue module tapped');
                  context.push('/lesson/detail', extra: {
                    'moduleId': 'current_module',
                    'moduleTitle': currentModuleName,
                    'moduleDescription': 'Continue your training',
                    'currentChapter': currentChapter,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Today's exercises
  Widget _buildTodaysExercises() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's exercises",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  AppLogger.i('View module tapped');
                  context.push('/lesson/detail', extra: {
                    'moduleId': 'current_module',
                    'moduleTitle': currentModuleName,
                  });
                },
                child: Text(
                  'View module',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 현재 진행중인 카드 (크게 표시)
          if (currentExercise != null)
            _buildExerciseCard(currentExercise!, isLarge: true),
          
          if (completedExercises.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Completed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
          ],
          
          // 완료된 항목들 (작게 표시)
          ...completedExercises.map((exercise) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildExerciseCard(exercise, isLarge: false),
            ),
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, {bool isLarge = false}) {
    final bool isCompleted = exercise['isCompleted'] ?? false;
    
    return GestureDetector(
      onTap: () {
        AppLogger.i('Exercise tapped: ${exercise['title']}');
        // 해당 레슨/운동으로 이동
      },
      child: Container(
        padding: EdgeInsets.all(isLarge ? 16 : 12),
        decoration: BoxDecoration(
          color: isLarge 
            ? AppColors.primary.withOpacity(0.05)
            : Colors.grey.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isLarge 
              ? AppColors.primary.withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isLarge ? 50 : 40,
              height: isLarge ? 50 : 40,
              decoration: BoxDecoration(
                color: isCompleted 
                  ? Colors.green.withOpacity(0.1)
                  : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCompleted ? Icons.check_circle : _getExerciseIcon(exercise['type']),
                color: isCompleted ? Colors.green : AppColors.primary,
                size: isLarge ? 24 : 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['title'],
                    style: TextStyle(
                      fontSize: isLarge ? 16 : 14,
                      fontWeight: isLarge ? FontWeight.w600 : FontWeight.w500,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${exercise['type']} • ${exercise['duration']}',
                    style: TextStyle(
                      fontSize: isLarge ? 13 : 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (!isCompleted && isLarge)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  IconData _getExerciseIcon(String type) {
    switch (type) {
      case 'lesson':
        return Icons.book;
      case 'exercise':
        return Icons.fitness_center;
      case 'reflection':
        return Icons.edit_note;
      default:
        return Icons.play_circle_outline;
    }
  }

  // 3. Weekly learning goal
  Widget _buildWeeklyLearningGoal() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly learning goal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          if (weeklyGoal == null) ...[
            // 최초 설정
            Text(
              '이번 주는 몇 번 참석 가능한가요?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: List.generate(7, (index) {
                final days = index + 1;
                return ChoiceChip(
                  label: Text('$days일'),
                  selected: false,
                  onSelected: (selected) {
                    setState(() {
                      weeklyGoal = days;
                      AppLogger.i('Weekly goal set to $days days');
                    });
                  },
                );
              }),
            ),
          ] else ...[
            // 목표 설정 완료
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${weeklyProgress.where((p) => p).length}/$weeklyGoal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      weeklyGoal = null;
                    });
                  },
                  child: const Text('Change'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final isCompleted = index < weeklyProgress.length && weeklyProgress[index];
                final isToday = index == DateTime.now().weekday - 1;
                
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted 
                      ? AppColors.primary 
                      : isToday 
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: isToday 
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                  ),
                  child: Center(
                    child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text(
                          days[index],
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            color: isToday ? AppColors.primary : Colors.grey,
                          ),
                        ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  // 4. Daily focus
  Widget _buildDailyFocus() {
    return GestureDetector(
      onTap: () {
        AppLogger.i('Daily focus tapped');
        context.push('/daily-focus');
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daily focus',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (dailyFocus == null) ...[
              // 미설정 상태
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFB74D).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.center_focus_strong,
                      size: 32,
                      color: Color(0xFFFF9800),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "What's your focus today?",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF9800),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to set your daily goal',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 설정 완료 상태
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF66D9EF).withOpacity(0.1),
                      const Color(0xFF4AA3BA).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF66D9EF).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.flag,
                          size: 20,
                          color: Color(0xFF4AA3BA),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Today's focus",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4AA3BA),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dailyFocus!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (startReminder != null || endReminder != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (startReminder != null) ...[
                            Icon(Icons.alarm, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'Start: ${startReminder!.format(context)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                          if (startReminder != null && endReminder != null)
                            const SizedBox(width: 16),
                          if (endReminder != null) ...[
                            Icon(Icons.alarm_off, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'End: ${endReminder!.format(context)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'nav_home'.tr(), _selectedIndex == 0, () {
                setState(() {
                  _selectedIndex = 0;
                });
              }),
              _buildNavItem(Icons.school, 'nav_learn'.tr(), _selectedIndex == 1, () {
                setState(() {
                  _selectedIndex = 1;
                });
              }),
              _buildNavItem(Icons.psychology, 'nav_focus'.tr(), _selectedIndex == 2, () {
                setState(() {
                  _selectedIndex = 2;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        AppLogger.i('$label nav tapped');
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}