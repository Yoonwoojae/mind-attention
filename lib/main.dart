import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';
import 'app/router.dart';
import 'core/utils/logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.d('백그라운드 메시지 수신: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await EasyLocalization.ensureInitialized();
  
  await initializeFirebase();
  
  await initializeSupabase();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ko', 'KR'),
      child: const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

Future<void> initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    
    await setupFirebaseMessaging();
    
    AppLogger.d('✅ Firebase 초기화 완료');
  } catch (e) {
    AppLogger.d('❌ Firebase 초기화 실패: $e');
  }
}

Future<void> setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  
  AppLogger.d('알림 권한 상태: ${settings.authorizationStatus}');
  
  String? token = await messaging.getToken();
  AppLogger.d('FCM 토큰: $token');
  
  messaging.onTokenRefresh.listen((newToken) {
    AppLogger.d('FCM 토큰 갱신: $newToken');
  });
  
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    AppLogger.d('포그라운드 메시지 수신:');
    AppLogger.d('제목: ${message.notification?.title}');
    AppLogger.d('내용: ${message.notification?.body}');
  });
  
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    AppLogger.d('알림을 탭하여 앱 열림: ${message.messageId}');
  });
}

Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  AppLogger.d('✅ Supabase 초기화 완료');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Mind Attention',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D6A4F)),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}