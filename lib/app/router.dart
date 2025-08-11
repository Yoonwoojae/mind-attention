import 'package:go_router/go_router.dart';
import 'package:mind_attention/screens/intro.dart';
import 'package:mind_attention/screens/onboarding.dart';
import 'package:mind_attention/screens/auth/login.dart';
import 'package:mind_attention/screens/auth/signup.dart';
import 'package:mind_attention/screens/home/home.dart';
import 'package:mind_attention/screens/survey/survey.dart';
import 'package:mind_attention/screens/analysis/analysis_screen.dart';
import 'package:mind_attention/screens/plan_recommendation/plan_recommendation_screen.dart';
import 'package:mind_attention/screens/notification_settings/notification_settings_screen.dart';
import 'package:mind_attention/screens/app_benefits/app_benefits_screen.dart';
import 'package:mind_attention/screens/push_notification_guide/push_notification_guide_screen.dart';
import 'package:mind_attention/screens/subscription/subscription_screen.dart';
import 'package:mind_attention/screens/user_customization/user_customization_screen.dart';
import 'package:mind_attention/screens/roadmap/roadmap_screen.dart';
import 'package:mind_attention/screens/first_lesson/first_lesson_screen.dart';
import 'package:mind_attention/screens/learn/learn_screen.dart';
import 'package:mind_attention/screens/learn/lesson_detail/lesson_detail_screen.dart';
import 'package:mind_attention/screens/learn/lesson_template/lesson_template.dart';
import 'package:mind_attention/screens/learn/lesson_template/exercise_template.dart';
import 'package:mind_attention/screens/learn/lesson_template/reflection_template.dart';
import 'package:mind_attention/screens/learn/lesson_template/feedback_template.dart';
import 'package:mind_attention/screens/learn/topic_lessons_screen.dart';
import 'package:mind_attention/screens/home/daily_focus_screen.dart';
import 'package:mind_attention/screens/focus/focus_screen.dart';
import 'package:mind_attention/screens/focus/timer/adhd_timer_screen.dart';
import 'package:mind_attention/screens/focus/task_breakdown/task_breakdown_screen.dart';
import 'package:mind_attention/screens/focus/reset/focus_reset_screen.dart';
import 'package:mind_attention/screens/focus/environment/environment_setup_screen.dart';
import 'package:mind_attention/screens/placeholder_screens.dart';
import 'package:flutter/material.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const IntroScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/daily-focus',
      builder: (context, state) => const DailyFocusScreen(),
    ),
    GoRoute(
      path: '/survey',
      builder: (context, state) => const SurveyScreen(),
    ),
    GoRoute(
      path: '/analysis',
      builder: (context, state) => const AnalysisScreen(),
    ),
    GoRoute(
      path: '/plan-recommendation',
      builder: (context, state) => const PlanRecommendationScreen(),
    ),
    GoRoute(
      path: '/notification-settings',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/app-benefits',
      builder: (context, state) => const AppBenefitsScreen(),
    ),
    GoRoute(
      path: '/push-notification-guide',
      builder: (context, state) => const PushNotificationGuideScreen(),
    ),
    GoRoute(
      path: '/subscription',
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: '/user-customization',
      builder: (context, state) => const UserCustomizationScreen(),
    ),
    GoRoute(
      path: '/roadmap',
      builder: (context, state) => const RoadmapScreen(),
    ),
    GoRoute(
      path: '/first-lesson',
      builder: (context, state) => const FirstLessonScreen(),
    ),
    // Learn 관련 라우트들
    GoRoute(
      path: '/learn',
      builder: (context, state) => const LearnScreen(),
    ),
    // Completed modules route removed - not implemented yet
    GoRoute(
      path: '/learn/topic',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final topic = extra?['topic'] ?? '';
        return TopicLessonsScreen(topic: topic);
      },
    ),
    GoRoute(
      path: '/lesson/detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return LessonDetailScreen(
          moduleId: extra?['moduleId'] ?? '',
          moduleTitle: extra?['moduleTitle'] ?? '',
          moduleDescription: extra?['moduleDescription'] ?? '',
          moduleImage: extra?['moduleImage'] ?? '',
        );
      },
    ),
    GoRoute(
      path: '/lesson/template/:type',
      builder: (context, state) {
        final type = state.pathParameters['type'] ?? '';
        final extra = state.extra as Map<String, dynamic>?;
        
        switch (type) {
          case 'lesson':
            return LessonTemplate(
              moduleId: extra?['moduleId'] ?? '',
              sessionId: extra?['sessionId'] ?? '',
              lessonData: extra?['data'] ?? {},
              onComplete: () => context.pop(),
            );
          case 'exercise':
            return ExerciseTemplate(
              moduleId: extra?['moduleId'] ?? '',
              sessionId: extra?['sessionId'] ?? '',
              exerciseData: extra?['data'] ?? {},
              onComplete: () => context.pop(),
            );
          case 'reflection':
            return ReflectionTemplate(
              moduleId: extra?['moduleId'] ?? '',
              sessionId: extra?['sessionId'] ?? '',
              reflectionData: extra?['data'] ?? {},
              onComplete: () => context.pop(),
            );
          case 'feedback':
            return FeedbackTemplate(
              moduleId: extra?['moduleId'] ?? '',
              sessionId: extra?['sessionId'] ?? '',
              feedbackData: extra?['data'] ?? {},
              onComplete: () => context.pop(),
            );
          default:
            return Scaffold(
              appBar: AppBar(title: Text('Unknown Template')),
              body: Center(child: Text('Unknown template type: $type')),
            );
        }
      },
    ),
    GoRoute(
      path: '/module/detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final title = extra?['title'] ?? '';
        return ModuleDetailScreen(title: title);
      },
    ),
    GoRoute(
      path: '/module/review',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final title = extra?['title'] ?? '';
        return ModuleReviewScreen(title: title);
      },
    ),
    GoRoute(
      path: '/focus',
      builder: (context, state) => const FocusScreen(),
    ),
    GoRoute(
      path: '/focus/timer',
      builder: (context, state) {
        final uri = Uri.parse(state.uri.toString());
        final duration = int.tryParse(uri.queryParameters['duration'] ?? '');
        return ADHDTimerScreen(initialDuration: duration);
      },
    ),
    GoRoute(
      path: '/focus/task-breakdown',
      builder: (context, state) => const TaskBreakdownScreen(),
    ),
    GoRoute(
      path: '/focus/reset',
      builder: (context, state) {
        final uri = Uri.parse(state.uri.toString());
        final mode = uri.queryParameters['mode'];
        return FocusResetScreen(mode: mode);
      },
    ),
    GoRoute(
      path: '/focus/environment',
      builder: (context, state) => const EnvironmentSetupScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

class ModuleDetailScreen extends StatelessWidget {
  final String title;
  const ModuleDetailScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('모듈 상세: $title'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('뒤로 가기'),
            ),
          ],
        ),
      ),
    );
  }
}

class ModuleReviewScreen extends StatelessWidget {
  final String title;
  const ModuleReviewScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$title 복습'),
      ),
      body: Center(
        child: Text('$title 복습 모드'),
      ),
    );
  }
}

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus'),
      ),
      body: const Center(
        child: Text('Focus 화면'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile 화면'),
      ),
    );
  }
}
