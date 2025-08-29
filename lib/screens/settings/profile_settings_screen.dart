import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/toast_utils.dart';
import '../../core/utils/translation_utils.dart';
import '../../core/services/encryption_service.dart';

class EncryptedData {
  final String encrypted;
  final String iv;
  EncryptedData({required this.encrypted, required this.iv});
}

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isLoading = false;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final supabase = Supabase.instance.client;
        final response = await supabase
            .schema('mind_attention_play')
            .from('users')
            .select('encrypted_profile_name, profile_name_iv, encrypted_bio, bio_iv, profile_image_url')
            .eq('id', user.uid)
            .single();

        if (response['encrypted_profile_name'] != null) {
          final encryptionService = EncryptionService();
          final decryptedName = encryptionService.decryptText(
            response['encrypted_profile_name'],
          );
          if (decryptedName != null) {
            _nameController.text = decryptedName;
          }
        }

        if (response['encrypted_bio'] != null) {
          final encryptionService = EncryptionService();
          final decryptedBio = encryptionService.decryptText(
            response['encrypted_bio'],
          );
          if (decryptedBio != null) {
            _bioController.text = decryptedBio;
          }
        }

        setState(() {
          _profileImageUrl = response['profile_image_url'];
        });
      }
    } catch (e) {
      AppLogger.e('Failed to load profile', e);
      if (mounted) {
        ToastUtils.showErrorToast(context, tr('profile_load_error'));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null) {
        final encryptionService = EncryptionService();
        final encryptedName = encryptionService.encryptText(_nameController.text);
        final encryptedBio = encryptionService.encryptText(_bioController.text);

        final supabase = Supabase.instance.client;
        await supabase.schema('mind_attention_play').from('users').update({
          'encrypted_profile_name': encryptedName,
          'profile_name_iv': '',
          'encrypted_bio': encryptedBio,
          'bio_iv': '',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.uid);

        if (mounted) {
          ToastUtils.showSuccessToast(context, tr('profile_update_success'));
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      AppLogger.e('Failed to update profile', e);
      if (mounted) {
        ToastUtils.showErrorToast(context, tr('profile_update_error'));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('settings_profile')),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : null,
                      child: _profileImageUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        ToastUtils.showInfoToast(context, tr('profile_image_coming_soon'));
                      },
                      child: Text(tr('profile_change_image')),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: tr('profile_name'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return tr('profile_name_required');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _bioController,
                      decoration: InputDecoration(
                        labelText: tr('profile_bio'),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        child: Text(tr('profile_save')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}