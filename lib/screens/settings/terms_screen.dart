import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:flutter/services.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/translation_utils.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  String _termsContent = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTerms();
  }

  Future<void> _loadTerms() async {
    try {
      final isKorean = ez.EasyLocalization.of(context)!.locale.languageCode == 'ko';
      final fileName = isKorean ? 'terms_ko.txt' : 'terms_en.txt';
      
      final content = await rootBundle.loadString('assets/legal/$fileName').catchError((e) {
        AppLogger.e('Failed to load terms file', e);
        return isKorean 
            ? '''서비스 이용약관

제1조 (목적)
이 약관은 Mind Attention(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (정의)
1. "서비스"란 회사가 제공하는 Mind Attention 애플리케이션 및 관련 서비스를 의미합니다.
2. "이용자"란 본 약관에 따라 서비스를 이용하는 자를 의미합니다.

제3조 (약관의 효력 및 변경)
1. 본 약관은 서비스를 이용하고자 하는 모든 이용자에게 적용됩니다.
2. 회사는 필요한 경우 약관을 변경할 수 있으며, 변경된 약관은 공지사항을 통해 공지합니다.

제4조 (서비스의 제공)
1. 회사는 다음과 같은 서비스를 제공합니다:
   - 명상 및 마음챙김 콘텐츠
   - 학습 프로그램
   - 개인 진도 관리
2. 서비스는 연중무휴, 1일 24시간 제공함을 원칙으로 합니다.

제5조 (이용자의 의무)
1. 이용자는 서비스 이용 시 관련 법령을 준수해야 합니다.
2. 타인의 개인정보를 침해하거나 부정하게 사용해서는 안 됩니다.

제6조 (개인정보보호)
회사는 이용자의 개인정보를 개인정보처리방침에 따라 안전하게 보호합니다.

제7조 (면책조항)
회사는 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 책임이 면제됩니다.

제8조 (준거법 및 관할법원)
본 약관은 대한민국 법령에 따라 규율되고 해석됩니다.

부칙
본 약관은 2024년 1월 1일부터 시행됩니다.'''
            : '''Terms of Service

Article 1 (Purpose)
These terms aim to define the rights, obligations, and responsibilities between the company and users regarding the use of Mind Attention (hereinafter "Service").

Article 2 (Definitions)
1. "Service" means the Mind Attention application and related services provided by the company.
2. "User" means a person who uses the Service in accordance with these terms.

Article 3 (Effect and Changes of Terms)
1. These terms apply to all users who wish to use the Service.
2. The company may change the terms if necessary, and the changed terms will be announced through notices.

Article 4 (Provision of Service)
1. The company provides the following services:
   - Meditation and mindfulness content
   - Learning programs
   - Personal progress management
2. The Service is provided 24 hours a day, 365 days a year in principle.

Article 5 (User Obligations)
1. Users must comply with relevant laws when using the Service.
2. Users must not infringe or illegally use others' personal information.

Article 6 (Privacy Protection)
The company safely protects users' personal information according to the privacy policy.

Article 7 (Disclaimer)
The company is exempted from responsibility when unable to provide the Service due to force majeure.

Article 8 (Governing Law and Jurisdiction)
These terms are governed and interpreted according to the laws of the Republic of Korea.

Supplementary Provisions
These terms are effective from January 1, 2024.''';
      });

      setState(() {
        _termsContent = content;
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.e('Failed to load terms', e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings_terms')),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Text(
                _termsContent,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
    );
  }
}