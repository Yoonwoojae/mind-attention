# Mind Attention 프로젝트 개발 가이드

## 🚨 필수 개발 규칙

### 1. 다국어 처리 (i18n)
- **모든 UI 텍스트는 반드시 `.tr()` 함수로 감싸기**
- 번역 파일 위치: `assets/translations/`
  - `ko-KR.json` (한국어)
  - `en-US.json` (영어)
- **번역 키 규칙: 플랫(flat) 구조 사용 - 중첩 금지!**
- lib/core/utils/translation_utils.dart 파일사용.
  ```dart
  // ❌ 잘못된 예시
  Text('로그인')
  
  // ✅ 올바른 예시
  Text(tr('login_title'))
  ```
  ```json
  // ❌ 잘못된 번역 파일 (중첩 구조)
  {
    "login": {
      "title": "로그인"
    }
  }
  
  // ✅ 올바른 번역 파일 (플랫 구조)
  {
    "login_title": "로그인",
    "login_button": "로그인하기",
    "login_error_message": "로그인 실패"
  }
  ```

### 2. 로깅
- **모든 로그는 `AppLogger` 클래스 사용**
  ```dart
  AppLogger.d('디버그 메시지');
  AppLogger.e('에러 메시지');
  AppLogger.i('정보 메시지');
  ```
- `print()` 사용 금지

### 3. 빌드 및 테스트
- **빌드/테스트 명령 실행 금지**
- 코드 작성만 진행

### 4. 작업 확인 프로세스
- **코드 수정 전 반드시 사용자에게 확인 요청**
- 명확한 작업 지시가 있을 때만 코드 수정
- 질문에는 답변만, 코드 수정 금지

### 5. 아키텍처 원칙
- **심플한 구조 유지**
- Model 클래스 사용 안 함
- Provider 패턴 사용 안 함
- 직접적이고 단순한 코드 작성

### 6. 데이터 보안
- **모든 민감한 데이터는 암호화 필수**
- `lib/core/services/encryption_service.dart` 활용
  ```dart
  // 암호화
  final encrypted = await EncryptionService.encrypt(data);
  // 복호화
  final decrypted = await EncryptionService.decrypt(encrypted);
  ```

## 📁 프로젝트 구조
```
lib/
├── core/
│   ├── services/
│   │   ├── analytics_service.dart    # Firebase Analytics
│   │   ├── crashlytics_service.dart  # 오류 추적
│   │   └── encryption_service.dart   # 암복호화
│   └── utils/
│       ├── logger.dart               # 로깅 유틸
│       ├── toast_utils.dart          # 토스트 메시지
│       └── translation_utils.dart    # 번역 유틸
├── screens/                          # 화면 파일들
└── main.dart                         # 앱 진입점

assets/
└── translations/
    ├── ko-KR.json                   # 한국어 번역
    └── en-US.json                   # 영어 번역
```

## 🔧 기술 스택
- **Firebase**: Auth, Analytics, Crashlytics, Messaging, Performance, Remote Config
- **Supabase**: 데이터베이스
- **easy_localization**: 다국어 지원
- **flutter_riverpod**: 상태 관리 (최소한으로만 사용)
- **go_router**: 네비게이션

## ⚠️ 중요 참고사항
1. Firebase와 Supabase의 User 클래스 충돌 주의
   - Firebase Auth는 `firebase_auth.User` 사용
2. Analytics의 `setCurrentScreen`은 deprecated
   - `logScreenView` 사용
3. 번역 키는 반드시 유니크하고 플랫한 구조로 작성

## 🗄️ 데이터베이스 주의사항

### 스키마
- **스키마명**: `mind_attention_play`
- 모든 테이블은 이 스키마 아래에 생성

### 암호화 필수 필드
다음 데이터는 **반드시 암호화**하여 저장:
```dart
// users 테이블
- encrypted_email (+ email_iv)
- encrypted_profile_name (+ profile_name_iv)  
- encrypted_bio (+ bio_iv)

// user_responses 테이블
- encrypted_response (+ response_iv)  // 저널, 일기 등 민감한 내용

// 암호화 예시
final encryptedData = await EncryptionService.encrypt(plainText);
// DB에 encryptedData.encrypted와 encryptedData.iv 모두 저장
```

### Firebase UID 사용
- `users.id`는 Firebase UID를 그대로 사용
- Supabase RLS 정책에서 `auth.uid()`로 접근 제어

### 테이블 통합 구조
- ❌ 별도 테이블: `user_module_progress`, `user_session_progress`, `user_item_progress`
- ✅ 통합 테이블: `user_progress` (progress_type으로 구분)

### JSONB 사용 최소화
- 검색/필터링이 필요한 데이터는 정규화된 컬럼으로
- 메타데이터나 로깅용 추가 정보만 JSONB 사용

### FCM 토큰 관리
```dart
// user_devices 테이블에 FCM 토큰 저장
// 토큰 갱신 시 업데이트 필수
FirebaseMessaging.instance.onTokenRefresh.listen((token) {
  // user_devices 테이블 업데이트
});
```

### 알림 큐 관리
- `notification_queue`: 예약된 알림은 여기에 먼저 저장
- 백그라운드 작업으로 주기적으로 발송 처리
- 실패 시 retry_count 증가 후 재시도

### 인덱스 전략
- 초기에는 최소한의 인덱스만 생성
- 실제 쿼리 성능 모니터링 후 필요시 추가
- 쓰기 성능 vs 읽기 성능 균형 고려

### 트리거 주의사항
- `updated_at` 자동 업데이트 트리거 활성화됨
- 통계 자동 업데이트 트리거로 `user_statistics` 테이블 자동 갱신
- 트리거 로직 변경 시 기존 트리거 DROP 후 재생성 필요
