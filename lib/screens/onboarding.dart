import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mind_attention/widgets/common/bottom_fixed_button.dart';
import 'package:mind_attention/core/constants/app_colors.dart';

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
      svgPath: 'assets/images/onboarding/meditation_1.svg',
      backgroundColor: const Color(0xFFE8F5E9),
      accentColor: AppColors.primary,
    ),
    OnboardingContent(
      title: 'onboarding_title_2',
      description: 'onboarding_desc_2',
      svgPath: 'assets/images/onboarding/smiley-face_2.svg',
      backgroundColor: const Color(0xFFFFEBEE),
      accentColor: const Color(0xFFE91E63),
    ),
    OnboardingContent(
      title: 'onboarding_title_3',
      description: 'onboarding_desc_3',
      svgPath: 'assets/images/onboarding/dreamer_3.svg',
      backgroundColor: const Color(0xFFE3F2FD),
      accentColor: const Color(0xFF2196F3),
    ),
    OnboardingContent(
      title: 'onboarding_title_4',
      description: 'onboarding_desc_4',
      svgPath: 'assets/images/onboarding/new-message_4.svg',
      backgroundColor: const Color(0xFFFFF3E0),
      accentColor: const Color(0xFFFF9800),
    ),
    OnboardingContent(
      title: 'onboarding_title_5',
      description: 'onboarding_desc_5',
      svgPath: 'assets/images/onboarding/medical-research_5.svg',
      backgroundColor: const Color(0xFFF3E5F5),
      accentColor: const Color(0xFF9C27B0),
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
          backgroundColor: isPrimary ? AppColors.primary : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AppColors.primary,
          elevation: isPrimary ? 2 : 0,
          side: isPrimary ? null : const BorderSide(
            color: AppColors.primary,
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
              height: 56,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _currentPage < _contents.length - 1
                  ? TextButton(
                      onPressed: _skipToEnd,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'onboarding_skip'.tr(),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
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
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  content.backgroundColor,
                                  Colors.white,
                                ],
                                stops: const [0.0, 0.6],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  const Spacer(flex: 1),
                                  // SVG 이미지
                                  Container(
                                    height: 280,
                                    padding: const EdgeInsets.all(20),
                                    child: SvgPicture.asset(
                                      content.svgPath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  // 제목
                                  Text(
                                    content.title.tr(),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: content.accentColor,
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  // 설명
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      content.description.tr(),
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: Colors.grey[700],
                                        height: 1.6,
                                        letterSpacing: -0.2,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const Spacer(flex: 2),
                                ],
                              ),
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
                  activeDotColor: AppColors.primary,
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
  final String svgPath;
  final Color backgroundColor;
  final Color accentColor;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.svgPath,
    required this.backgroundColor,
    required this.accentColor,
  });
}