import 'dart:developer' as developer;

class LogFilter {
  static void configureLogging() {
    // Android 에뮬레이터 관련 로그 필터링
    developer.postEvent('configureLogging', {
      'filter': [
        'EGL_emulation',
        'app_time_stats',
        'gralloc4',
        'HostConnection',
        'OpenGLRenderer',
      ]
    });
  }
}