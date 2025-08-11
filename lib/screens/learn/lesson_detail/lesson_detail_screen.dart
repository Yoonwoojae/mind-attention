import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LessonDetailScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;
  final String moduleDescription;
  final String moduleImage;

  const LessonDetailScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
    required this.moduleDescription,
    required this.moduleImage,
  });

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  int currentSessionIndex = 0; // 현재 진행해야 할 세션 인덱스
  int completedSessions = 0; // 완료된 세션 수
  
  final List<Session> sessions = [
    Session(
      number: 1,
      title: 'Own your growth edges',
      items: [
        SessionItem(type: 'lesson', title: 'Own your growth edges'),
      ],
      isCompleted: false,
      isCurrent: true,
    ),
    Session(
      number: 2,
      title: 'Talk to your past self',
      items: [
        SessionItem(type: 'lesson', title: 'Talk to your past self'),
        SessionItem(type: 'reflection', title: 'Reflect on your learning'),
      ],
      isCompleted: false,
      isCurrent: false,
    ),
    Session(
      number: 3,
      title: 'Take a break from social media',
      items: [
        SessionItem(type: 'lesson', title: 'Take a break from social media'),
        SessionItem(type: 'exercise', title: 'Practice identifying triggers'),
      ],
      isCompleted: false,
      isCurrent: false,
    ),
    Session(
      number: 4,
      title: 'Practice affirmations that work',
      items: [
        SessionItem(type: 'lesson', title: 'Practice affirmations that work'),
        SessionItem(type: 'exercise', title: 'Create your affirmations'),
        SessionItem(type: 'reflection', title: 'Daily affirmation log'),
        SessionItem(type: 'feedback', title: 'Your progress summary'),
      ],
      isCompleted: false,
      isCurrent: false,
    ),
  ];

  double get progressPercentage {
    if (sessions.isEmpty) return 0.0;
    return completedSessions / sessions.length;
  }

  void _startModule() {
    // 테스트: 현재 세션의 첫 번째 아이템 타입에 따라 템플릿 테스트
    final currentSession = sessions[currentSessionIndex];
    if (currentSession.items.isNotEmpty) {
      final firstItem = currentSession.items.first;
      _navigateToTemplate(firstItem.type);
    }
  }
  
  void _navigateToTemplate(String type) {
    // 테스트 데이터로 각 템플릿 화면 표시
    final testData = _getTestDataForType(type);
    
    context.push(
      '/lesson/template/$type',
      extra: {
        'moduleId': widget.moduleId,
        'sessionId': 'test_$type',
        'data': testData,
      },
    );
  }
  
  Map<String, dynamic> _getTestDataForType(String type) {
    switch (type) {
      case 'lesson':
        return {
      'title': 'Understanding ADHD and Focus',
      'subtitle': 'Learn how ADHD affects your attention and discover strategies',
      'dayInfo': 'Day 1 / 3',
      'image': '',
      'audio': {
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', // 테스트용 오디오
        'timestamps': [
          {'section_index': 0, 'start_time': 0.0, 'end_time': 5.0},
          {'section_index': 1, 'start_time': 5.0, 'end_time': 15.0},
          {'section_index': 2, 'start_time': 15.0, 'end_time': 25.0},
          {'section_index': 3, 'start_time': 25.0, 'end_time': 35.0},
          {'section_index': 4, 'start_time': 35.0, 'end_time': 50.0},
          {'section_index': 5, 'start_time': 50.0, 'end_time': 65.0},
          {'section_index': 6, 'start_time': 65.0, 'end_time': 80.0},
        ],
      },
      'sections': [
        {'type': 'heading', 'content': 'Why is focus difficult with ADHD?'},
        {'type': 'text', 'content': 'ADHD affects the brain\'s executive functions, making it challenging to maintain attention on tasks that aren\'t immediately rewarding or stimulating.'},
        {'type': 'subheading', 'content': 'The Science Behind It'},
        {'type': 'text', 'content': 'Research shows that ADHD brains have differences in dopamine regulation, which affects motivation and attention. This isn\'t a character flaw - it\'s neurobiology.'},
        {'type': 'bullet_list', 'items': [
          'Difficulty filtering out distractions',
          'Challenges with sustained mental effort',
          'Tendency to hyperfocus on interesting tasks',
          'Executive function differences'
        ]},
        {'type': 'info_box', 'content': 'Remember: ADHD is not about lack of attention, but rather difficulty regulating attention.'},
        {'type': 'quote', 'content': 'ADHD is not a deficit of attention, but rather an abundance of it. The challenge is directing it.', 'author': 'Dr. Edward Hallowell'},
      ],
      'highlights': ['executive functions', 'dopamine regulation', 'not a character flaw'],
    };
      
      case 'exercise':
        return {
      'title': 'Focus Strategies Quiz',
      'questions': [
        {
          'type': 'multiple_choice',
          'question': 'Which strategy is most effective for managing ADHD distractions?',
          'context': 'Consider strategies that work with ADHD brain patterns, not against them.',
          'options': [
            'Force yourself to concentrate harder',
            'Break tasks into smaller, manageable chunks',
            'Work for hours without breaks',
            'Eliminate all environmental stimuli'
          ],
          'correctAnswer': 'Break tasks into smaller, manageable chunks',
          'correctFeedback': 'Excellent! Breaking tasks down makes them less overwhelming and more achievable.',
          'incorrectFeedback': 'Breaking tasks into smaller chunks is usually more effective for ADHD brains.',
          'explanation': 'ADHD brains respond better to small, achievable goals rather than large, overwhelming tasks. Breaking tasks down activates the reward system more frequently, maintaining motivation and focus.',
        },
        {
          'type': 'true_false',
          'question': 'ADHD medication is the only effective treatment for improving focus.',
          'correctAnswer': false,
          'correctFeedback': 'Correct! While medication can help, behavioral strategies, therapy, and lifestyle changes are also very effective.',
          'incorrectFeedback': 'Actually, many non-medication strategies like CBT, exercise, and mindfulness are also proven to help.',
          'explanation': 'Research shows that a combination of approaches works best for ADHD. Cognitive Behavioral Therapy (CBT), regular exercise, mindfulness practices, and lifestyle modifications can significantly improve focus and executive function.',
        },
        {
          'type': 'situation',
          'question': 'You have an important report due tomorrow but keep getting distracted. What should you do?',
          'situations': [
            {
              'id': 'pomodoro',
              'title': 'Use the Pomodoro Technique',
              'description': 'Work for 25 minutes, then take a 5-minute break. Repeat.'
            },
            {
              'id': 'marathon',
              'title': 'Power through without breaks',
              'description': 'Lock yourself in and work until it\'s done.'
            },
            {
              'id': 'multitask',
              'title': 'Work on multiple tasks at once',
              'description': 'Switch between tasks to stay engaged.'
            },
          ],
          'correctAnswer': 'pomodoro',
          'correctFeedback': 'Great choice! The Pomodoro Technique works well with ADHD by providing structure and regular breaks.',
          'incorrectFeedback': 'The Pomodoro Technique is often more effective as it provides breaks and structure.',
          'explanation': 'The Pomodoro Technique (25 minutes work, 5 minutes break) is particularly effective for ADHD because it creates urgency, provides regular dopamine rewards through breaks, and prevents mental fatigue. The time constraint helps overcome procrastination and the breaks prevent burnout.',
        },
      ],
    };
      
      case 'reflection':
        return {
      'title': 'Daily Reflection',
      'description': 'Take a moment to reflect on your experience with today\'s lesson and how you can apply it.',
      'questions': [
        {
          'id': 'difficulty',
          'type': 'scale',
          'title': 'How difficult was today\'s training?',
          'description': 'Rate from 1 (very easy) to 5 (very difficult)',
          'min': 1,
          'max': 5,
          'labels': {'min': 'Very Easy', 'max': 'Very Difficult'},
          'required': true,
        },
        {
          'id': 'satisfaction',
          'type': 'slider',
          'title': 'How satisfied are you with your progress?',
          'min': 0,
          'max': 100,
          'divisions': 10,
          'required': true,
        },
        {
          'id': 'applied',
          'type': 'radio',
          'title': 'Did you apply any strategies from the lesson today?',
          'options': ['Yes, multiple times', 'Yes, once', 'Not yet, but I plan to', 'No'],
          'required': true,
        },
        {
          'id': 'challenges',
          'type': 'checkbox',
          'title': 'What challenges did you face? (Select all that apply)',
          'options': [
            'Difficulty understanding the concept',
            'Hard to stay focused',
            'Not enough time',
            'Technical issues',
            'Content not relevant to me'
          ],
          'required': false,
        },
        {
          'id': 'notes',
          'type': 'textarea',
          'title': 'What was your biggest takeaway from today?',
          'placeholder': 'Share your thoughts, insights, or questions...',
          'required': false,
        },
        {
          'id': 'tomorrow',
          'type': 'text',
          'title': 'One thing you\'ll try tomorrow:',
          'placeholder': 'e.g., Use timer for tasks',
          'required': true,
        },
      ],
    };
      
      case 'feedback':
        return {
      'title': 'Week 1 Progress Report',
      'scores': {
        'Lesson Completion': 85.0,
        'Exercise Accuracy': 72.0,
        'Daily Reflections': 90.0,
        'Strategy Application': 65.0,
      },
      'achievements': [
        {'icon': 'star', 'title': 'First Week', 'isNew': true},
        {'icon': 'trophy', 'title': 'Perfect Attendance', 'isNew': true},
        {'icon': 'fire', 'title': '3-Day Streak', 'isNew': false},
        {'icon': 'diamond', 'title': 'Quick Learner', 'isNew': false},
      ],
      'strengths': [
        'Consistent daily practice - you haven\'t missed a day!',
        'Strong understanding of ADHD concepts',
        'Excellent self-reflection in daily journals',
        'High engagement with interactive exercises',
      ],
      'improvements': [
        'Try to apply strategies more frequently in daily life',
        'Spend more time on challenging exercises',
        'Consider setting specific implementation goals',
      ],
      'recommendations': [
        {
          'title': 'Set Implementation Reminders',
          'description': 'Use phone alerts to remind yourself to practice new strategies throughout the day.',
        },
        {
          'title': 'Join Practice Groups',
          'description': 'Connect with others learning similar strategies for mutual support.',
        },
      ],
      'nextSteps': [
        'Continue with Module 2: Time Management Strategies',
        'Practice the Pomodoro Technique at least once daily',
        'Complete the mid-week check-in assessment',
        'Review and reinforce this week\'s key concepts',
      ],
    };
      
      default:
        return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 상단 이미지 영역
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.shade300,
                          Colors.orange.shade100,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.self_improvement,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              // 레슨 타이틀과 설명 섹션 추가
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 레슨 타이틀
                      Text(
                        // widget.moduleTitle,
                        'title',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 레슨 설명
                      Text(
                        // widget.moduleDescription,
                        'description',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              
              // 세션 목록
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final session = sessions[index];
                      final isCurrent = index == currentSessionIndex;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 세션 번호와 제목
                            Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 8),
                              child: Text(
                                '${session.number}. ${session.title}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: session.isCompleted 
                                    ? Colors.grey[400]
                                    : const Color(0xFF2C3E50),
                                ),
                              ),
                            ),
                            
                            // 세션 아이템들
                            if (isCurrent) 
                              // 현재 세션은 크게 표시
                              _buildCurrentSessionCard(session)
                            else
                              // 나머지 세션들은 작게 표시
                              ...session.items.map((item) => 
                                InkWell(
                                  onTap: () => _navigateToTemplate(item.type),
                                  child: _buildSessionItemCard(item, session.isCompleted),
                                )
                              ),
                          ],
                        ),
                      );
                    },
                    childCount: sessions.length,
                  ),
                ),
              ),
            ],
          ),
          
          // 하단 버튼 및 진행도
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 진행도 표시
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Progress',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              Text(
                                '${(progressPercentage * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressPercentage,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF2D6A4F),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Start module 버튼
                      ElevatedButton(
                        onPressed: _startModule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D6A4F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 52),
                        ),
                        child: const Text(
                          'Start module',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // 현재 진행해야 할 세션 카드 (크게 표시)
  Widget _buildCurrentSessionCard(Session session) {
    return InkWell(
      onTap: () {
        if (session.items.isNotEmpty) {
          _navigateToTemplate(session.items.first.type);
        }
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // 이미지 영역
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.shade100,
                    Colors.blue.shade50,
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.local_florist,
                      size: 40,
                      color: Colors.orange.shade400,
                    ),
                  ),
                ),
              ),
            ),
            // 텍스트 영역
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Lesson',
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
      ),
    );
  }
  
  // 일반 세션 아이템 카드 (작게 표시)
  Widget _buildSessionItemCard(SessionItem item, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getItemColor(item.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getItemIcon(item.type),
                  size: 24,
                  color: _getItemColor(item.type),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isCompleted 
                        ? Colors.grey[400]
                        : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        _getItemTypeIcon(item.type),
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getItemTypeText(item.type),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 체크 아이콘 또는 잠금 아이콘
            if (isCompleted)
              Icon(
                Icons.check_circle,
                size: 20,
                color: Colors.green.shade400,
              )
            else if (item.isLocked ?? false)
              Icon(
                Icons.lock_outline,
                size: 20,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }
  
  IconData _getItemIcon(String type) {
    switch (type) {
      case 'lesson':
        return Icons.local_florist;
      case 'exercise':
        return Icons.quiz;
      case 'reflection':
        return Icons.edit_note;
      case 'feedback':
        return Icons.insights;
      default:
        return Icons.circle;
    }
  }
  
  IconData _getItemTypeIcon(String type) {
    switch (type) {
      case 'lesson':
        return Icons.book_outlined;
      case 'exercise':
        return Icons.quiz_outlined;
      case 'reflection':
        return Icons.edit_outlined;
      case 'feedback':
        return Icons.analytics_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
  
  String _getItemTypeText(String type) {
    switch (type) {
      case 'lesson':
        return 'Lesson';
      case 'exercise':
        return 'Exercise';
      case 'reflection':
        return 'Reflection';
      case 'feedback':
        return 'Feedback';
      default:
        return type;
    }
  }
  
  Color _getItemColor(String type) {
    switch (type) {
      case 'lesson':
        return Colors.blue;
      case 'exercise':
        return Colors.green;
      case 'reflection':
        return Colors.purple;
      case 'feedback':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class Session {
  final int number;
  final String title;
  final List<SessionItem> items;
  final bool isCompleted;
  final bool isCurrent;

  Session({
    required this.number,
    required this.title,
    required this.items,
    required this.isCompleted,
    required this.isCurrent,
  });
}

class SessionItem {
  final String type;
  final String title;
  final bool? isLocked;

  SessionItem({
    required this.type,
    required this.title,
    this.isLocked,
  });
}
