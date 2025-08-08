// lib/core/services/encryption_service.dart
import 'dart:convert';
import 'dart:typed_data';
import '../utils/logger.dart';

class EncryptionService {
  static final _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  // 앱 고유 키 (실제 배포시에는 더 복잡한 키 사용 권장)
  static const String _appKey = 'mindAttention2024SecretKey!@##@!@&*^';

  /// 텍스트 암호화 (단순 XOR + Base64)
  String? encryptText(String? plainText) {
    if (plainText == null || plainText.isEmpty) return plainText;

    try {
      final bytes = utf8.encode(plainText);
      final keyBytes = utf8.encode(_appKey);
      final encrypted = <int>[];

      for (int i = 0; i < bytes.length; i++) {
        encrypted.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return base64Encode(encrypted);
    } catch (e) {
      AppLogger.d('텍스트 암호화 실패: $e');
      return plainText;
    }
  }

  /// 텍스트 복호화
  String? decryptText(String? encryptedText) {
    if (encryptedText == null || encryptedText.isEmpty) return encryptedText;

    try {
      final encrypted = base64Decode(encryptedText);
      final keyBytes = utf8.encode(_appKey);
      final decrypted = <int>[];

      for (int i = 0; i < encrypted.length; i++) {
        decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      AppLogger.d('텍스트 복호화 실패: $e');
      return encryptedText;
    }
  }

  /// JSON 객체 암호화
  String? encryptJson(dynamic data) {
    if (data == null) return null;
    try {
      final jsonString = jsonEncode(data); // List도 Map도 모두 처리 가능
      return encryptText(jsonString);
    } catch (e) {
      AppLogger.e('JSON 암호화 오류: $e');
      return null;
    }
  }

  /// JSON 객체 복호화
  Map<String, dynamic>? decryptJson(String? encryptedJson) {
    if (encryptedJson == null || encryptedJson.isEmpty) return null;

    try {
      AppLogger.d('복호화전값 : $encryptedJson');
      final decryptedString = decryptText(encryptedJson);
      AppLogger.d('복호화후값 : $decryptedString');
      if (decryptedString == null) return null;
      return jsonDecode(decryptedString);
    } catch (e) {
      AppLogger.d('JSON 복호화 실패: $e');
      return null;
    }
  }

  /// 리스트 암호화
  List<String>? encryptList(List<String>? plainList) {
    if (plainList == null || plainList.isEmpty) return plainList;

    try {
      return plainList.map((item) => encryptText(item) ?? item).toList();
    } catch (e) {
      AppLogger.d('리스트 암호화 실패: $e');
      return plainList;
    }
  }

  /// 리스트 복호화
  List<String>? decryptList(List<String>? encryptedList) {
    if (encryptedList == null || encryptedList.isEmpty) return encryptedList;

    try {
      return encryptedList.map((item) => decryptText(item) ?? item).toList();
    } catch (e) {
      AppLogger.d('리스트 복호화 실패: $e');
      return encryptedList;
    }
  }
}
