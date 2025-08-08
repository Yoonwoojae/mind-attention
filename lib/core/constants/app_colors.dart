import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2D6A4F); // 로고와 동일한 초록색
  static const Color primaryLight = Color(0xFF52B788); // 연한 초록
  static const Color primaryDark = Color(0xFF1B5E3F); // 진한 초록
  
  // Secondary colors  
  static const Color secondary = Color(0xFFB7E4C7); // 매우 연한 초록 (배경용)
  static const Color secondaryLight = Color(0xFFD8F3DC); // 더 연한 초록
  
  // Accent colors
  static const Color accent = Color(0xFFFF6B6B); // 강조색 (빨간색 계열)
  static const Color warning = Color(0xFFFFA500); // 경고색 (주황색)
  static const Color success = Color(0xFF40916C); // 성공색 (중간 초록)
  
  // Neutral colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F5F5);
  static const Color border = Color(0xFFE0E0E0);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}