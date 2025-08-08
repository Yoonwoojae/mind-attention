import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:mind_attention/core/utils/logger.dart';
import 'package:mind_attention/widgets/common/bottom_fixed_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<double>> _slideAnimations;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: 'onboarding_title_1',
      description: 'onboarding_desc_1',
      icon: Icons.center_focus_strong,
      color: const Color(0xFF6B73FF),
    ),
    OnboardingContent(
      title: 'onboarding_title_2',
      description: 'onboarding_desc_2',
      icon: Icons.favorite_outline,
      color: const Color(0xFFFF6B9D),
    ),
    OnboardingContent(
      title: 'onboarding_title_3',
      description: 'onboarding_desc_3',
      icon: Icons.nights_stay_outlined,
      color: const Color(0xFF66D9EF),
    ),
    OnboardingContent(
      title: 'onboarding_title_4',
      description: 'onboarding_desc_4',
      icon: Icons.notifications_outlined,
      color: const Color(0xFFFECA57),
    ),
    OnboardingContent(
      title: 'onboarding_title_5',
      description: 'onboarding_desc_5',
      icon: Icons.science_outlined,
      color: const Color(0xFF48DBB4),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      _contents.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      ),
    );

    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      ));
    }).toList();

    _slideAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 30.0,
        end: 0.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));
    }).toList();

    _animationControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _animationControllers[page].forward();
  }

  void _nextPage() {
    if (_currentPage < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showAuthOptions();
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _contents.length - 1,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _showAuthOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              _buildAuthButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/login');
                },
                text: 'onboarding_login'.tr(),
                isPrimary: true,
              ),
              const SizedBox(height: 12),
              _buildAuthButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/signup');
                },
                text: 'onboarding_signup'.tr(),
                isPrimary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required VoidCallback onPressed,
    required String text,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF6B73FF) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF6B73FF),
          elevation: isPrimary ? 2 : 0,
          side: isPrimary ? null : const BorderSide(
            color: Color(0xFF6B73FF),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: _currentPage < _contents.length - 1 ? _skipToEnd : null,
                child: Text(
                  _currentPage < _contents.length - 1 ? 'onboarding_skip'.tr() : '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  final content = _contents[index];
                  return AnimatedBuilder(
                    animation: _animationControllers[index],
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimations[index],
                        child: Transform.translate(
                          offset: Offset(0, _slideAnimations[index].value),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: content.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Icon(
                                    content.icon,
                                    size: 60,
                                    color: content.color,
                                  ),
                                ),
                                const SizedBox(height: 48),
                                Text(
                                  content.title.tr(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3436),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  content.description.tr(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            BottomFixedButton(
              text: _currentPage < _contents.length - 1
                  ? 'onboarding_next'.tr()
                  : 'onboarding_start'.tr(),
              onPressed: _nextPage,
              additionalContent: SmoothPageIndicator(
                controller: _pageController,
                count: _contents.length,
                effect: ExpandingDotsEffect(
                  activeDotColor: const Color(0xFF6B73FF),
                  dotColor: Colors.grey[300]!,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 8,
                  expansionFactor: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}