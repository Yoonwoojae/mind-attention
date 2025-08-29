import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:flutter/services.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/translation_utils.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  String _privacyContent = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacy();
  }

  Future<void> _loadPrivacy() async {
    try {
      final isKorean = ez.EasyLocalization.of(context)!.locale.languageCode == 'ko';
      final fileName = isKorean ? 'privacy_ko.txt' : 'privacy_en.txt';
      
      final content = await rootBundle.loadString('assets/legal/$fileName').catchError((e) {
        AppLogger.e('Failed to load privacy file', e);
        return isKorean 
            ? '''개인정보처리방침

Mind Attention(이하 "회사")은 이용자의 개인정보를 중요시하며, 개인정보보호법을 준수하고 있습니다.

1. 수집하는 개인정보 항목
- 필수항목: 이메일 주소, 닉네임
- 선택항목: 프로필 사진, 자기소개
- 자동수집: 서비스 이용기록, 접속 로그, 기기정보

2. 개인정보의 수집 및 이용목적
- 회원 관리: 회원제 서비스 제공, 본인확인
- 서비스 제공: 콘텐츠 제공, 맞춤 서비스 제공
- 서비스 개선: 통계학적 분석, 서비스 개선

3. 개인정보의 보유 및 이용기간
- 회원 탈퇴 시까지
- 관련 법령에 따른 보관 의무가 있는 경우 해당 기간

4. 개인정보의 암호화
회사는 이용자의 민감한 개인정보를 암호화하여 저장하고 관리합니다.
- 이메일, 닉네임, 자기소개 등은 암호화 처리
- SSL/TLS를 통한 전송 구간 암호화

5. 개인정보의 파기
- 이용목적 달성 후 즉시 파기
- 전자적 파일: 복구 불가능한 방법으로 영구 삭제

6. 이용자의 권리
- 개인정보 열람, 정정, 삭제 요구
- 개인정보 처리정지 요구
- 회원 탈퇴

7. 개인정보보호 책임자
- 이메일: privacy@mindattention.com

8. 개인정보처리방침 변경
본 방침은 2024년 1월 1일부터 적용됩니다.'''
            : '''Privacy Policy

Mind Attention (hereinafter "Company") values users' personal information and complies with privacy protection laws.

1. Personal Information Collected
- Required: Email address, Nickname
- Optional: Profile picture, Bio
- Automatic: Service usage records, Access logs, Device information

2. Purpose of Collection and Use
- Member management: Membership service provision, Identity verification
- Service provision: Content delivery, Personalized services
- Service improvement: Statistical analysis, Service enhancement

3. Retention and Use Period
- Until membership withdrawal
- Period required by relevant laws if applicable

4. Encryption of Personal Information
The company encrypts and manages users' sensitive personal information.
- Email, nickname, bio are encrypted
- Transmission encryption via SSL/TLS

5. Destruction of Personal Information
- Immediate destruction after purpose achievement
- Electronic files: Permanent deletion by irreversible methods

6. User Rights
- Request to view, correct, or delete personal information
- Request to stop processing personal information
- Membership withdrawal

7. Privacy Officer
- Email: privacy@mindattention.com

8. Changes to Privacy Policy
This policy is effective from January 1, 2024.''';
      });

      setState(() {
        _privacyContent = content;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.e('Failed to load privacy', e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings_privacy')),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _privacyContent,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
    );
  }
}