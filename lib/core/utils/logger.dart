// lib/core/utils/logger.dart
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // 개발 환경 로그
  static void d(String message) {
    _logger.d(message);
  }

  // 정보 로그
  static void i(String message) {
    _logger.i(message);
  }

  // 경고 로그
  static void w(String message) {
    _logger.w(message);
  }

  // 에러 로그
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // 프로덕션 환경에서는 중요한 로그만 출력하도록 설정할 수 있습니다
  static void setup({bool isProduction = false}) {
    if (isProduction) {
      Logger.level = Level.warning; // 프로덕션에서는 warning 이상만 로깅
    } else {
      Logger.level = Level.debug; // 개발 환경에서는 모든 로그 출력
    }
  }
}
