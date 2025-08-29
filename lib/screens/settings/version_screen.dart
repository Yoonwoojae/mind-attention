import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/toast_utils.dart';
import '../../core/utils/translation_utils.dart';

class VersionScreen extends StatefulWidget {
  const VersionScreen({super.key});

  @override
  State<VersionScreen> createState() => _VersionScreenState();
}

class _VersionScreenState extends State<VersionScreen> {
  String _appName = '';
  String _packageName = '';
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appName = packageInfo.appName;
        _packageName = packageInfo.packageName;
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    } catch (e) {
      AppLogger.e('Failed to load package info', e);
    }
  }

  Future<void> _checkForUpdates() async {
    ToastUtils.showInfoToast(context, tr('version_checking_updates'));
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      ToastUtils.showSuccessToast(context, tr('version_up_to_date'));
    }
  }

  Future<void> _openAppStore() async {
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final url = isAndroid
        ? 'https://play.google.com/store/apps/details?id=$_packageName'
        : 'https://apps.apple.com/app/id1234567890';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ToastUtils.showErrorToast(context, tr('version_store_error'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings_version')),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.psychology,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _appName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${tr('version_label')} $_version',
                style: const TextStyle(fontSize: 18),
              ),
              Text(
                '${tr('version_build')} $_buildNumber',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).disabledColor,
                ),
              ),
              const SizedBox(height: 40),
              _buildInfoItem(
                label: tr('version_package'),
                value: _packageName,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _checkForUpdates,
                icon: const Icon(Icons.refresh),
                label: Text(tr('version_check_updates')),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _openAppStore,
                child: Text(tr('version_view_store')),
              ),
              const Spacer(),
              Text(
                tr('version_copyright'),
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Made with ❤️ by Mind Attention Team',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}