import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as ez;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/translation_utils.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .schema('mind_attention_play')
          .from('announcements')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      setState(() {
        _announcements = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.e('Failed to load announcements', e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings_announcements')),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _announcements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.campaign_outlined,
                        size: 64,
                        color: Theme.of(context).disabledColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        tr('announcements_empty'),
                        style: TextStyle(
                          color: Theme.of(context).disabledColor,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _announcements.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final announcement = _announcements[index];
                    final isKorean = ez.EasyLocalization.of(context)!.locale.languageCode == 'ko';
                    final title = isKorean
                        ? (announcement['title_ko'] ?? announcement['title'])
                        : announcement['title'];
                    final content = isKorean
                        ? (announcement['content_ko'] ?? announcement['content'])
                        : announcement['content'];
                    final createdAt = DateTime.parse(announcement['created_at']);
                    final formattedDate = ez.DateFormat('yyyy.MM.dd').format(createdAt);

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (announcement['is_important'] == true)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      tr('announcements_important'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                if (announcement['is_important'] == true)
                                  const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              content,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).disabledColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
