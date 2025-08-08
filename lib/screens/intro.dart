import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:go_router/go_router.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:mind_attention/core/utils/logger.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isCheckingAuth = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _controller.forward();
    _checkAuthAfterDelay();
  }

  Future<void> _checkAuthAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isCheckingAuth = true;
      });
      await _checkAuthStatus();
    }
  }

  Future<void> _checkAuthStatus() async {
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      
      if (!mounted) return;
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (user != null) {
        AppLogger.i('User logged in: ${user.uid}');
        context.go('/home');
      } else {
        AppLogger.i('No user logged in, showing onboarding');
        context.go('/onboarding');
      }
    } catch (e) {
      AppLogger.e('Error checking auth status: $e');
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6B73FF),
              Color(0xFF000DFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.psychology_outlined,
                            size: 70,
                            color: Color(0xFF6B73FF),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        child: AnimatedTextKit(
                          totalRepeatCount: 1,
                          animatedTexts: [
                            TypewriterAnimatedText(
                              'intro_app_name'.tr(),
                              speed: const Duration(milliseconds: 100),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'intro_tagline'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
                if (_isCheckingAuth)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'intro_loading'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}