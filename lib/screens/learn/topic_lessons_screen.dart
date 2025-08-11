import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/logger.dart';
import '../../core/constants/app_colors.dart';

class TopicLessonsScreen extends StatelessWidget {
  final String topic;
  
  const TopicLessonsScreen({
    super.key,
    required this.topic,
  });
  
  // 토픽별 레슨 데이터 (실제로는 서비스에서 가져와야 함)
  List<Map<String, dynamic>> _getLessonsForTopic() {
    // 각 토픽별로 다른 레슨 목록 반환
    final lessons = {
      'learn_topic_productivity': [
        {
          'id': 'time_management_basics',
          'title': '시간 관리 기초',
          'description': '효율적인 일정 관리와 우선순위 설정 방법을 배워보세요',
          'duration': '10-15분',
          'difficulty': '초급',
          'image': 'assets/images/lessons/time_management.jpg',
          'sessions': 5,
        },
        {
          'id': 'pomodoro_technique',
          'title': '포모도로 기법 마스터',
          'description': '25분 집중, 5분 휴식의 과학적 시간 관리법',
          'duration': '5-10분',
          'difficulty': '초급',
          'image': 'assets/images/lessons/pomodoro.jpg',
          'sessions': 4,
        },
        {
          'id': 'deep_work_strategies',
          'title': '딥워크 전략',
          'description': '방해받지 않고 깊이 몰입하는 작업 환경 만들기',
          'duration': '15-20분',
          'difficulty': '중급',
          'image': 'assets/images/lessons/deep_work.jpg',
          'sessions': 6,
        },
      ],
      'learn_topic_wellbeing': [
        {
          'id': 'stress_reduction_101',
          'title': '스트레스 감소 기초',
          'description': '일상에서 실천할 수 있는 스트레스 관리 기법',
          'duration': '10-15분',
          'difficulty': '초급',
          'image': 'assets/images/lessons/stress.jpg',
          'sessions': 7,
        },
        {
          'id': 'mindful_breathing',
          'title': '마음챙김 호흡법',
          'description': '호흡을 통한 즉각적인 마음 안정 기법',
          'duration': '5-10분',
          'difficulty': '초급',
          'image': 'assets/images/lessons/breathing.jpg',
          'sessions': 5,
        },
        {
          'id': 'emotional_balance',
          'title': '감정 균형 찾기',
          'description': '감정을 인식하고 건강하게 표현하는 방법',
          'duration': '15-20분',
          'difficulty': '중급',
          'image': 'assets/images/lessons/emotions.jpg',
          'sessions': 8,
        },
      ],
      'learn_topic_adhd_challenges': [
        {
          'id': 'focus_training_adhd',
          'title': 'ADHD를 위한 집중력 훈련',
          'description': 'ADHD 특성에 맞춘 맞춤형 집중력 향상 프로그램',
          'duration': '10-15분',
          'difficulty': '중급',
          'image': 'assets/images/lessons/adhd_focus.jpg',
          'sessions': 10,
        },
        {
          'id': 'impulse_control',
          'title': '충동 조절 연습',
          'description': '충동적 행동을 인식하고 조절하는 실용적 전략',
          'duration': '15-20분',
          'difficulty': '중급',
          'image': 'assets/images/lessons/impulse.jpg',
          'sessions': 8,
        },
        {
          'id': 'executive_function',
          'title': '실행 기능 강화',
          'description': '계획, 조직화, 실행 능력을 체계적으로 향상',
          'duration': '20-25분',
          'difficulty': '고급',
          'image': 'assets/images/lessons/executive.jpg',
          'sessions': 12,
        },
      ],
    };
    
    // 기본 레슨 목록 (다른 토픽들에 대해)
    final defaultLessons = [
      {
        'id': 'basic_lesson_1',
        'title': '기초 마음챙김 훈련',
        'description': '현재 순간에 집중하고 마음을 관찰하는 기초 훈련',
        'duration': '10-15분',
        'difficulty': '초급',
        'image': 'assets/images/lessons/default1.jpg',
        'sessions': 6,
      },
      {
        'id': 'basic_lesson_2',
        'title': '일상 속 명상',
        'description': '바쁜 일상에서도 실천 가능한 짧은 명상법',
        'duration': '5-10분',
        'difficulty': '초급',
        'image': 'assets/images/lessons/default2.jpg',
        'sessions': 5,
      },
      {
        'id': 'basic_lesson_3',
        'title': '마음 근육 키우기',
        'description': '지속적인 훈련으로 정신적 회복력 강화',
        'duration': '15-20분',
        'difficulty': '중급',
        'image': 'assets/images/lessons/default3.jpg',
        'sessions': 8,
      },
    ];
    
    // topic 키를 기반으로 레슨 반환
    for (var key in lessons.keys) {
      if (topic.contains(key.tr())) {
        return lessons[key]!;
      }
    }
    
    return defaultLessons;
  }
  
  @override
  Widget build(BuildContext context) {
    final lessons = _getLessonsForTopic();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          topic,
          style: const TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lessons.length,
        itemBuilder: (context, index) {
          final lesson = lessons[index];
          return _buildLessonCard(context, lesson);
        },
      ),
    );
  }
  
  Widget _buildLessonCard(BuildContext context, Map<String, dynamic> lesson) {
    return GestureDetector(
      onTap: () {
        AppLogger.i('Lesson tapped: ${lesson['title']}');
        // 레슨 화면으로 이동
        context.push('/lesson/detail', extra: {
          'moduleId': lesson['id'],
          'moduleTitle': lesson['title'],
          'moduleDescription': lesson['description'],
          'moduleImage': lesson['image'],
          'instanceId': 'instance_${DateTime.now().millisecondsSinceEpoch}',
          'isNewStart': true,
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 왼쪽 이미지
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.3),
                    AppColors.primary.withOpacity(0.6),
                  ],
                ),
              ),
              child: Center(
                child: Icon(
                  _getIconForLesson(lesson['id']),
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            // 오른쪽 내용
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      lesson['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // 설명
                    Text(
                      lesson['description'],
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // 메타 정보
                    Row(
                      children: [
                        // 난이도
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(lesson['difficulty']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            lesson['difficulty'],
                            style: TextStyle(
                              fontSize: 11,
                              color: _getDifficultyColor(lesson['difficulty']),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // 세션 수
                        Row(
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${lesson['sessions']}개 세션',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        // 시간
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lesson['duration'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // 화살표
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getIconForLesson(String lessonId) {
    final iconMap = {
      'time_management_basics': Icons.schedule,
      'pomodoro_technique': Icons.timer,
      'deep_work_strategies': Icons.psychology,
      'stress_reduction_101': Icons.spa,
      'mindful_breathing': Icons.air,
      'emotional_balance': Icons.favorite,
      'focus_training_adhd': Icons.center_focus_strong,
      'impulse_control': Icons.pan_tool,
      'executive_function': Icons.account_tree,
    };
    
    return iconMap[lessonId] ?? Icons.self_improvement;
  }
  
  Color _getDifficultyColor(String difficulty) {
    if (difficulty == '초급') {
      return Colors.green;
    } else if (difficulty == '중급') {
      return Colors.orange;
    } else if (difficulty == '고급') {
      return Colors.red;
    }
    return Colors.blue;
  }
}