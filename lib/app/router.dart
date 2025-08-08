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
  ],
);