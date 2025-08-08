import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isAnalyzing = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    // 3초 후 분석 완료
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
        _animationController.stop();
        // 1초 후 플랜 추천 화면으로 이동
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.go('/plan-recommendation');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 분석 아이콘 애니메이션
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 3.14159,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF6B73FF),
                              const Color(0xFF000DFF),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),
              // 분석중 텍스트
              Text(
                _isAnalyzing ? 'analysis_in_progress'.tr() : 'analysis_complete'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isAnalyzing ? 'analysis_description'.tr() : 'analysis_complete_description'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              // 프로그레스 인디케이터
              if (_isAnalyzing)
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF6B73FF),
                    ),
                  ),
                ),
              if (!_isAnalyzing)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
            ],
          ),
        ),
      ),
    );
  }
}