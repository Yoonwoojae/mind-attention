// lib/core/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:mind_attention/core/utils/logger.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: _analytics);

  // 🔥 페이지뷰 (GoRouter가 자동 호출)
  static Future<void> setCurrentScreen(String screenName) async {
    try {
      // setCurrentScreen이 deprecated되어 logScreenView 사용
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenName,
      );
      AppLogger.d('Analytics: Screen view - $screenName');
    } catch (e) {
      AppLogger.d('Analytics logScreenView 오류: $e');
    }
  }

  // 🔥 사용자 속성 설정
  static Future<void> setUserProperty(String name, String value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      AppLogger.d('Analytics: User property - $name: $value');
    } catch (e) {
      AppLogger.d('Analytics setUserProperty 오류: $e');
    }
  }

  // 🔥 프리미엄 관련 이벤트들
  static Future<void> logPremiumPageEnter(String source) async {
    await _logEvent('premium_page_enter', {'source': source});
  }

  static Future<void> logPricingCardClick(String planType) async {
    await _logEvent('pricing_card_click', {'plan_type': planType});
  }

  static Future<void> logPurchaseDialogOpen(String planType) async {
    await _logEvent('purchase_dialog_open', {'plan_type': planType});
  }

  static Future<void> logPurchaseDialogCancel(String planType) async {
    await _logEvent('purchase_dialog_cancel', {'plan_type': planType});
  }

  static Future<void> logPurchaseButtonClick(String planType) async {
    await _logEvent('purchase_button_click', {'plan_type': planType});
  }

  static Future<void> logFeatureComparisonView() async {
    await _logEvent('feature_comparison_view', {});
  }

  static Future<void> logPromotionBannerView(String promotionName) async {
    await _logEvent('promotion_banner_view', {'promotion_name': promotionName});
  }

  static Future<void> logRestorePurchaseClick() async {
    await _logEvent('restore_purchase_click', {});
  }

  // 🔥 일반 이벤트
  static Future<void> logEmotionRecorded() async {
    await _logEvent('emotion_recorded', {});
  }

  static Future<void> logActivityCompleted(String activityType) async {
    await _logEvent('activity_completed', {'activity_type': activityType});
  }

  static Future<void> logAiChatStarted() async {
    await _logEvent('ai_chat_started', {});
  }

  // 🔥 구매 완료 (가장 중요!)
  static Future<void> logPurchaseCompleted(String planType, double value) async {
    await _logEvent('purchase', {
      'currency': 'KRW',
      'value': value,
      'plan_type': planType,
    });
  }

  // 🔥 내부 헬퍼 함수
  static Future<void> _logEvent(String name, Map<String, dynamic> parameters) async {
    try {
      // Map<String, dynamic>를 Map<String, Object>로 캐스팅
      final castedParameters = parameters.cast<String, Object>();
      await _analytics.logEvent(name: name, parameters: castedParameters);
      AppLogger.d('Analytics: Event - $name: $parameters');
    } catch (e) {
      AppLogger.d('Analytics logEvent 오류: $e');
    }
  }

  // 🔥 사용자 ID 설정 (로그인 시)
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      AppLogger.d('Analytics: User ID set - $userId');
    } catch (e) {
      AppLogger.d('Analytics setUserId 오류: $e');
    }
  }

  // 🔥 프리미엄 상태 설정
  static Future<void> setPremiumStatus(bool isPremium) async {
    await setUserProperty('is_premium_user', isPremium.toString());
  }

  // 🔥 홈 페이지 이벤트
  static Future<void> logEmotionRecordButtonClick() async {
    await _logEvent('emotion_record_button_click', {});
  }

  static Future<void> logAiChatButtonClick() async {
    await _logEvent('ai_chat_button_click', {});
  }

  static Future<void> logPremiumBannerClick(String source) async {
    await _logEvent('premium_banner_click', {'source': source});
  }

// 🔥 기록 페이지 이벤트
  static Future<void> logActivityStarted(String activityType) async {
    await _logEvent('activity_started', {'activity_type': activityType});
  }

  static Future<void> logPremiumFeatureAttempt(String featureType) async {
    await _logEvent('premium_feature_attempt', {'feature_type': featureType});
  }

// 🔥 AI 친구 이벤트
  static Future<void> logAiMessageSent() async {
    await _logEvent('ai_message_sent', {});
  }

  static Future<void> logPremiumLimitReached(String limitType) async {
    await _logEvent('premium_limit_reached', {'limit_type': limitType});
  }

// 🔥 인사이트 이벤트
  static Future<void> logInsightsViewed() async {
    await _logEvent('insights_viewed', {});
  }

// 🔥 설정 이벤트
  static Future<void> logSettingsChanged(String settingType) async {
    await _logEvent('settings_changed', {'setting_type': settingType});
  }
}
