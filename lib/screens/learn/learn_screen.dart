import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:mind_attention/core/utils/logger.dart';
import 'package:mind_attention/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  bool _isYourModules = true;
  bool _showAllCompleted = false;
  
  // 임시 데이터 - 실제로는 서비스에서 관리
  final Map<String, dynamic> currentModule = {
    'id': 'focus_training_1',
    'instanceId': 'instance_001', // 각 시작마다 고유 ID
    'title': '물건 위치 기억 훈련',
    'totalSessions': 3,
    'completedSessions': 1,
    'progress': 0.33,
    'startedAt': '2024.01.20',
  };
  
  final List<Map<String, dynamic>> completedModules = [
    {
      'id': 'breathing_basics',
      'instanceId': 'instance_002',
      'title': '호흡 기초 훈련',
      'completedAt': '2024.01.15',
      'totalSessions': 4,
    },
    {
      'id': 'sleep_routine',
      'instanceId': 'instance_003',
      'title': '수면 루틴 만들기',
      'completedAt': '2024.01.10',
      'totalSessions': 5,
    },
    {
      'id': 'emotion_control',
      'instanceId': 'instance_004',
      'title': '감정 조절 훈련',
      'completedAt': '2024.01.05',
      'totalSessions': 7,
    },
    {
      'id': 'focus_training_1',
      'instanceId': 'instance_005', // 같은 훈련이지만 다른 인스턴스
      'title': '물건 위치 기억 훈련',
      'completedAt': '2024.01.01',
      'totalSessions': 3,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'learn_title'.tr(),
          style: const TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF2D3436)),
            onPressed: () {
              AppLogger.i('Search modules tapped');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
            child: _isYourModules ? _buildYourModules() : _buildAllModules(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isYourModules = true;
                  });
                  AppLogger.i('Your modules selected');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _isYourModules ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _isYourModules
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'learn_your_modules'.tr(),
                      style: TextStyle(
                        fontWeight: _isYourModules ? FontWeight.w600 : FontWeight.normal,
                        color: _isYourModules ? AppColors.primary : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isYourModules = false;
                  });
                  AppLogger.i('All modules selected');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !_isYourModules ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: !_isYourModules
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'learn_all_modules'.tr(),
                      style: TextStyle(
                        fontWeight: !_isYourModules ? FontWeight.w600 : FontWeight.normal,
                        color: !_isYourModules ? AppColors.primary : Colors.grey[600],
                      ),
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

  Widget _buildYourModules() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentModule(),
          const SizedBox(height: 24),
          _buildCompletedSection(),
        ],
      ),
    );
  }

  Widget _buildCurrentModule() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'learn_current_module'.tr(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'learn_module_focus_title'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'learn_chapter_progress'.tr().replaceAll('{current}', '3').replaceAll('{total}', '8'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'learn_progress'.tr(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '38%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.38,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 6,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              AppLogger.i('Continue module tapped: ${currentModule['id']}');
              // 현재 진행중인 모듈의 세션 목록으로 이동
              context.push('/lesson/detail', extra: {
                'moduleId': currentModule['id'],
                'moduleTitle': currentModule['title'],
                'moduleDescription': 'Continue your training',
                'moduleImage': 'assets/images/lessons/focus.svg',
                'instanceId': currentModule['instanceId'],
                'currentSession': currentModule['completedSessions'],
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('learn_continue'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'learn_completed'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _showAllCompleted = !_showAllCompleted;
                });
                AppLogger.i('Toggle show all: $_showAllCompleted');
              },
              child: Text(
                _showAllCompleted ? 'Show less' : 'learn_show_all'.tr(),
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_showAllCompleted)
          // 모든 완료된 모듈 표시 (세로 목록)
          Column(
            children: completedModules.map((module) => 
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildCompletedModuleListItem(module),
              )
            ).toList(),
          )
        else
          // 최근 3개만 가로 스크롤로 표시
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: completedModules.take(3).map((module) => 
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _buildCompletedModuleCard(
                    module: module,
                  ),
                )
              ).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildCompletedModuleCard({
    required Map<String, dynamic> module,
  }) {
    return GestureDetector(
      onTap: () {
        AppLogger.i('Completed module tapped: ${module['title']} (${module['instanceId']})');
        // 완료된 모듈도 다시 볼 수 있도록 세션 목록으로 이동
        context.push('/lesson/detail', extra: {
          'moduleId': module['id'],
          'moduleTitle': module['title'],
          'moduleDescription': 'Review completed training',
          'moduleImage': 'assets/images/lessons/completed.jpg',
          'instanceId': module['instanceId'],
          'isCompleted': true,
        });
      },
      child: Container(
        width: 160,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getModuleIcon(module['id']),
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              module['title'],
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              module['completedAt'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'learn_completed_label'.tr(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllModules() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeaturedSection(),
          const SizedBox(height: 24),
          _buildAllModulesRecommendedSection(),
          const SizedBox(height: 24),
          _buildTopicsSection(),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'learn_featured'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF66D9EF).withOpacity(0.9), const Color(0xFF4AA3BA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF66D9EF).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'learn_featured_badge'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'learn_featured_module_title'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'learn_featured_module_desc'.tr(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  AppLogger.i('Featured module tapped');
                  // Featured 모듈 직접 레슨 화면으로 이동
                  context.push('/lesson/detail', extra: {
                    'moduleId': 'featured_mindfulness',
                    'moduleTitle': 'learn_featured_module_title'.tr(),
                    'moduleDescription': 'learn_featured_module_desc'.tr(),
                    'moduleImage': 'assets/images/lessons/featured.jpg',
                    'instanceId': 'instance_${DateTime.now().millisecondsSinceEpoch}',
                    'isNewStart': true,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4AA3BA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('View Module'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'learn_topics'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildTopicCard('learn_topic_productivity'.tr(), Icons.trending_up, const Color(0xFFB8E6B8)),
            _buildTopicCard('learn_topic_wellbeing'.tr(), Icons.favorite, const Color(0xFFDDB8E6)),
            _buildTopicCard('learn_topic_daily_routines'.tr(), Icons.schedule, const Color(0xFFFFD4A3)),
            _buildTopicCard('learn_topic_adhd_challenges'.tr(), Icons.psychology, const Color(0xFFA3C4FF)),
            _buildTopicCard('learn_topic_organization'.tr(), Icons.folder, const Color(0xFFFFB8D1)),
            _buildTopicCard('learn_topic_relationships'.tr(), Icons.people, const Color(0xFFB8D4E6)),
            _buildTopicCard('learn_topic_self_improvement'.tr(), Icons.star, const Color(0xFFE6CCB8)),
            _buildTopicCard('learn_topic_unique_perspectives'.tr(), Icons.lightbulb, const Color(0xFFC3E6B8)),
          ],
        ),
      ],
    );
  }

  Widget _buildTopicCard(String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        AppLogger.i('Topic tapped: $title');
        context.push('/learn/topic', extra: {'topic': title});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color.withOpacity(0.8),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllModulesRecommendedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'learn_recommended'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildModuleListItem(
          id: 'mindfulness_basics',
          title: 'learn_module_beginner_focus_title'.tr(),
          description: 'learn_module_beginner_focus_desc'.tr(),
          duration: '5-10 min',
          difficulty: 'learn_difficulty_beginner'.tr(),
          sessions: 7,
          icon: Icons.psychology,
          color: AppColors.primary,
          reason: 'learn_recommended_based_on_interests'.tr(),
          image: 'assets/images/lessons/mindfulness_basics.jpg',
        ),
        const SizedBox(height: 12),
        _buildModuleListItem(
          id: 'sleep_better',
          title: 'learn_module_advanced_mindfulness_title'.tr(),
          description: 'learn_module_advanced_mindfulness_desc'.tr(),
          duration: '15-20 min',
          difficulty: 'learn_difficulty_advanced'.tr(),
          sessions: 10,
          icon: Icons.self_improvement,
          color: const Color(0xFF66D9EF),
          reason: 'learn_recommended_popular'.tr(),
          image: 'assets/images/lessons/sleep_better.jpg',
        ),
        const SizedBox(height: 12),
        _buildModuleListItem(
          id: 'stress_management',
          title: 'learn_module_stress_relief_title'.tr(),
          description: 'learn_module_stress_relief_desc'.tr(),
          duration: '10-15 min',
          difficulty: 'learn_difficulty_intermediate'.tr(),
          sessions: 5,
          icon: Icons.spa,
          color: const Color(0xFFFF6B9D),
          reason: 'learn_recommended_trending'.tr(),
          image: 'assets/images/lessons/stress_management.jpg',
        ),
      ],
    );
  }

  Widget _buildModuleListItem({
    String? id,
    required String title,
    required String description,
    required String duration,
    required String difficulty,
    required int sessions,
    required IconData icon,
    required Color color,
    String? reason,
    String? image,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(difficulty),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            difficulty,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$sessions ' + 'learn_sessions'.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          if (reason != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              AppLogger.i('Start module: $title');
              // 새로운 인스턴스 ID 생성 (실제로는 서비스에서 생성)
              final newInstanceId = 'instance_${DateTime.now().millisecondsSinceEpoch}';
              
              context.push('/lesson/detail', extra: {
                'moduleId': id ?? title.replaceAll(' ', '_').toLowerCase(),
                'moduleTitle': title,
                'moduleDescription': description,
                'moduleImage': image ?? 'assets/images/lessons/default.jpg',
                'instanceId': newInstanceId,
                'isNewStart': true,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.1),
              foregroundColor: color,
              elevation: 0,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'learn_start_module'.tr(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    if (difficulty.contains('Beginner') || difficulty.contains('초급')) {
      return Colors.green;
    } else if (difficulty.contains('Advanced') || difficulty.contains('고급')) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
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
              _buildNavItem(Icons.home, 'nav_home'.tr(), false, () {
                context.go('/home');
              }),
              _buildNavItem(Icons.school, 'nav_learn'.tr(), true, () {}),
              _buildNavItem(Icons.psychology, 'nav_focus'.tr(), false, () {
                context.push('/focus');
              }),
            ],
          ),
        ),
      ),
    );
  }

  // \uc644\ub8cc\ub41c \ubaa8\ub4c8\uc744 \ub9ac\uc2a4\ud2b8 \ud615\ud0dc\ub85c \ud45c\uc2dc\ud558\ub294 \uc704\uc82f \ucd94\uac00
  Widget _buildCompletedModuleListItem(Map<String, dynamic> module) {
    return GestureDetector(
      onTap: () {
        AppLogger.i('Completed module list item tapped: ${module['title']}');
        context.push('/lesson/detail', extra: {
          'moduleId': module['id'],
          'moduleTitle': module['title'],
          'moduleDescription': 'Review completed training',
          'moduleImage': 'assets/images/lessons/completed.jpg',
          'instanceId': module['instanceId'],
          'isCompleted': true,
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getModuleIcon(module['id']),
                color: Colors.green,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module['title'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed ${module['completedAt']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${module['totalSessions']} sessions',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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
  
  // \ubaa8\ub4c8 \uc544\uc774\ucf58 \ubc18\ud658 \ud568\uc218 \ucd94\uac00
  IconData _getModuleIcon(String moduleId) {
    switch (moduleId) {
      case 'breathing_basics':
        return Icons.air;
      case 'sleep_routine':
        return Icons.nightlight_round;
      case 'emotion_control':
        return Icons.favorite;
      case 'focus_training_1':
        return Icons.psychology;
      case 'stress_management':
        return Icons.spa;
      default:
        return Icons.self_improvement;
    }
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
