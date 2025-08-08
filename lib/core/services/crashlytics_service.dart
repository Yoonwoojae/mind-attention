// lib/core/services/crashlytics_service.dart
import 'package:mind_attention/core/utils/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  static final CrashlyticsService _instance = CrashlyticsService._internal();
  factory CrashlyticsService() => _instance;
  CrashlyticsService._internal();

  static CrashlyticsService get instance => _instance;

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  /// Crashlytics 초기화
  Future<void> initialize({required bool isProduction}) async {
    try {
      // 개발 환경에서는 Crashlytics 비활성화
      await _crashlytics.setCrashlyticsCollectionEnabled(isProduction);

      AppLogger.d('Crashlytics 초기화 완료 (활성화: $isProduction)');
    } catch (e) {
      AppLogger.e('Crashlytics 초기화 실패: $e');
    }
  }

  /// 사용자 식별자 설정
  Future<void> setUserIdentifier() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;
        await _crashlytics.setUserIdentifier(userId);
        AppLogger.d('Crashlytics 사용자 식별자 설정: $userId');
      }
    } catch (e) {
      AppLogger.e('사용자 식별자 설정 실패: $e');
    }
  }

  /// 커스텀 키-값 설정
  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
      AppLogger.d('Crashlytics 커스텀 키 설정: $key = $value');
    } catch (e) {
      AppLogger.e('커스텀 키 설정 실패: $e');
    }
  }

  /// 에러 기록
  Future<void> recordError(
      dynamic exception,
      StackTrace? stackTrace, {
        String? reason,
        bool fatal = false,
      }) async {
    try {
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
      AppLogger.d('Crashlytics 에러 기록: $exception');
    } catch (e) {
      AppLogger.e('에러 기록 실패: $e');
    }
  }

  /// 비치명적 에러 기록 (로그용)
  Future<void> recordNonFatalError(dynamic exception, StackTrace? stackTrace) async {
    await recordError(exception, stackTrace, fatal: false);
  }

  /// 로그 메시지 기록
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
    } catch (e) {
      AppLogger.e('Crashlytics 로그 기록 실패: $e');
    }
  }

  /// 사용자 로그아웃 시 식별자 제거
  Future<void> clearUserIdentifier() async {
    try {
      await _crashlytics.setUserIdentifier('');
      AppLogger.d('Crashlytics 사용자 식별자 제거');
    } catch (e) {
      AppLogger.e('사용자 식별자 제거 실패: $e');
    }
  }

  /// 테스트 크래시 (개발용)
  void testCrash() {
    if (kDebugMode) {
      _crashlytics.crash();
    }
  }
}
