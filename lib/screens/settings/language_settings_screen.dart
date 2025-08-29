import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import '../../core/utils/logger.dart';
import '../../core/utils/toast_utils.dart';
import '../../core/utils/translation_utils.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late String _selectedLanguage;
  bool _initialized = false;

  final List<Map<String, String>> _languages = [
    {'code': 'ko', 'name': '한국어', 'englishName': 'Korean'},
    {'code': 'en', 'name': 'English', 'englishName': 'English'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _selectedLanguage = ez.EasyLocalization.of(context)!.locale.languageCode;
      _initialized = true;
    }
  }

  Future<void> _changeLanguage(String languageCode) async {
    if (languageCode == _selectedLanguage) return;

    setState(() => _selectedLanguage = languageCode);

    try {
      if (languageCode == 'ko') {
        await ez.EasyLocalization.of(context)!.setLocale(const Locale('ko', 'KR'));
      } else {
        await ez.EasyLocalization.of(context)!.setLocale(const Locale('en', 'US'));
      }
      
      AppLogger.i('Language changed to: $languageCode');
      
      if (mounted) {
        ToastUtils.showSuccessToast(context, tr('language_change_success'));
        Navigator.of(context).pop();
      }
    } catch (e) {
      AppLogger.e('Failed to change language', e);
      if (mounted) {
        ToastUtils.showErrorToast(context, tr('language_change_error'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings_language')),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final language = _languages[index];
          final isSelected = language['code'] == _selectedLanguage;
          
          return ListTile(
            title: Text(language['name']!),
            subtitle: language['code'] != 'en'
                ? Text(language['englishName']!)
                : null,
            trailing: isSelected
                ? Icon(Icons.check, color: Theme.of(context).primaryColor)
                : null,
            onTap: () => _changeLanguage(language['code']!),
          );
        },
      ),
    );
  }
}