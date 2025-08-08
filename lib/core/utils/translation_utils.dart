// lib/core/utils/translation_utils.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:mind_attention/core/utils/logger.dart';

class TranslationUtils {
  // 누락된 번역 키들을 저장할 Set
  static final Set<String> _missingKeys = <String>{};

  /// 안전한 번역 메서드
  /// - [key]  : 번역 키
  /// - [args] : `{변수명: 값}` 형태로 전달하면 `{변수명}` 자리표시자가 값으로 치환됩니다.
  static String safeTr(String key, {Map<String, String>? args}) {
    try {
      // 번역 시도
      var translated = key.tr();

      // 번역이 실패했는지 확인 (키와 결과가 같으면 번역 실패)
      if (translated == key) {
        _logMissingKey(key);
      }

      // 자리표시자 치환
      if (args != null && args.isNotEmpty) {
        args.forEach((placeholder, value) {
          translated = translated.replaceAll('{$placeholder}', value);
        });
      }

      return translated;
    } catch (e) {
      _logMissingKey(key);
      // 번역 실패 시에도 자리표시자 치환은 적용
      var fallback = key;
      if (args != null && args.isNotEmpty) {
        args.forEach((placeholder, value) {
          fallback = fallback.replaceAll('{$placeholder}', value);
        });
      }
      return fallback;
    }
  }

  /// 번역 키 리스트 안전 처리
  static List<String> safeTrList(List<String> keys) {
    return keys.map((key) => safeTr(key)).toList();
  }

  /// 누락된 키 로깅
  static void _logMissingKey(String key) {
    if (!_missingKeys.contains(key)) {
      _missingKeys.add(key);
      // AppLogger.w('🔤 번역 누락: "$key"');

      // 개발 모드에서만 콘솔에도 출력
      const environment = String.fromEnvironment('ENV', defaultValue: 'development');
      if (environment == 'development') {
        print('🔤 Missing translation key: "$key"');
      }
    }
  }

  /// 누락된 번역 키들 가져오기
  static Set<String> getMissingKeys() {
    return Set.from(_missingKeys);
  }

  /// 누락된 키들을 JSON 형태로 출력
  static String getMissingKeysAsJson() {
    if (_missingKeys.isEmpty) {
      return '{}';
    }

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('{');

    final sortedKeys = _missingKeys.toList()..sort();
    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      buffer.write('  "$key": "$key"');
      if (i < sortedKeys.length - 1) {
        buffer.write(',');
      }
      buffer.writeln();
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  /// 누락된 키들 로그로 출력 (개발용)
  static void printMissingKeys() {
    if (_missingKeys.isNotEmpty) {
      AppLogger.i('📝 누락된 번역 키 목록 (${_missingKeys.length}개):');
      AppLogger.i(getMissingKeysAsJson());

      print('\n🔤 Missing Translation Keys JSON:');
      print(getMissingKeysAsJson());
    } else {
      AppLogger.i('✅ 모든 번역 키가 등록되어 있습니다.');
    }
  }

  /// 누락된 키 개수
  static int getMissingKeyCount() {
    return _missingKeys.length;
  }

  /// 누락된 키들 초기화 (테스트용)
  static void clearMissingKeys() {
    _missingKeys.clear();
  }
}

// 편의를 위한 전역 함수
String tr(String key, {Map<String, String>? args}) =>
    TranslationUtils.safeTr(key, args: args);

List<String> trList(List<String> keys) => TranslationUtils.safeTrList(keys);
