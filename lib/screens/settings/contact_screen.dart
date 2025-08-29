import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/toast_utils.dart';
import '../../core/utils/translation_utils.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'general';
  bool _isSubmitting = false;

  final List<Map<String, String>> _categories = [
    {'value': 'general', 'key': 'contact_category_general'},
    {'value': 'bug', 'key': 'contact_category_bug'},
    {'value': 'suggestion', 'key': 'contact_category_suggestion'},
    {'value': 'account', 'key': 'contact_category_account'},
    {'value': 'other', 'key': 'contact_category_other'},
  ];

  Future<void> _submitInquiry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final supabase = Supabase.instance.client;
        await supabase.schema('mind_attention_play').from('inquiries').insert({
          'user_id': user.uid,
          'category': _selectedCategory,
          'subject': _subjectController.text,
          'message': _messageController.text,
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          ToastUtils.showSuccessToast(context, tr('contact_submit_success'));
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      AppLogger.e('Failed to submit inquiry', e);
      if (mounted) {
        ToastUtils.showErrorToast(context, tr('contact_submit_error'));
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@mindattention.com',
      query: Uri.encodeFull(
        'subject=${tr('contact_email_subject')}&body=${tr('contact_email_body')}',
      ),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ToastUtils.showErrorToast(context, tr('contact_email_error'));
      }
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings_contact')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('contact_description'),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: tr('contact_category'),
                  border: const OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category['value'],
                    child: Text(tr(category['key']!)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  labelText: tr('contact_subject'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('contact_subject_required');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(
                  labelText: tr('contact_message'),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return tr('contact_message_required');
                  }
                  if (value.length < 10) {
                    return tr('contact_message_too_short');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitInquiry,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(tr('contact_submit')),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text(
                      tr('contact_alternative'),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _sendEmail,
                      icon: const Icon(Icons.email),
                      label: const Text('support@mindattention.com'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
