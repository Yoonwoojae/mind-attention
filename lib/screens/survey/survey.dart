import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_attention/core/utils/logger.dart';
import 'package:mind_attention/widgets/common/bottom_fixed_button.dart';
import 'package:mind_attention/core/constants/app_colors.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  String? _selectedGoal;
  String? _selectedExperience;
  String? _selectedStyle;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSurvey();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeSurvey() {
    AppLogger.i('Survey completed - Goal: $_selectedGoal, Experience: $_selectedExperience, Style: $_selectedStyle');
    
    // 분석 화면으로 이동
    context.go('/analysis');
  }

  Widget _buildAnalyzingDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'survey_analyzing'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'survey_analyzing_desc'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: _previousPage,
              )
            : null,
        title: Text(
          'survey_title'.tr(),
          style: const TextStyle(
            color: Color(0xFF2D3436),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / 3,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildGoalPage(),
                _buildExperiencePage(),
                _buildStylePage(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomFixedButton(
        text: _currentPage == 2 ? 'common_confirm'.tr() : 'onboarding_next'.tr(),
        onPressed: _canProceed() ? _nextPage : null,
      ),
    );
  }

  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'survey_goal_title'.tr(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildOptionCard(
                  value: 'stress',
                  title: 'survey_goal_stress'.tr(),
                  icon: Icons.spa,
                  isSelected: _selectedGoal == 'stress',
                  onTap: () {
                    setState(() {
                      _selectedGoal = 'stress';
                    });
                  },
                ),
                _buildOptionCard(
                  value: 'focus',
                  title: 'survey_goal_focus'.tr(),
                  icon: Icons.center_focus_strong,
                  isSelected: _selectedGoal == 'focus',
                  onTap: () {
                    setState(() {
                      _selectedGoal = 'focus';
                    });
                  },
                ),
                _buildOptionCard(
                  value: 'emotion',
                  title: 'survey_goal_emotion'.tr(),
                  icon: Icons.favorite_outline,
                  isSelected: _selectedGoal == 'emotion',
                  onTap: () {
                    setState(() {
                      _selectedGoal = 'emotion';
                    });
                  },
                ),
                _buildOptionCard(
                  value: 'sleep',
                  title: 'survey_goal_sleep'.tr(),
                  icon: Icons.nights_stay,
                  isSelected: _selectedGoal == 'sleep',
                  onTap: () {
                    setState(() {
                      _selectedGoal = 'sleep';
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperiencePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'survey_experience_title'.tr(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildOptionCard(
                  value: 'beginner',
                  title: 'survey_experience_beginner'.tr(),
                  icon: Icons.sentiment_satisfied,
                  isSelected: _selectedExperience == 'beginner',
                  onTap: () {
                    setState(() {
                      _selectedExperience = 'beginner';
                    });
                  },
                ),
                _buildOptionCard(
                  value: 'intermediate',
                  title: 'survey_experience_intermediate'.tr(),
                  icon: Icons.self_improvement,
                  isSelected: _selectedExperience == 'intermediate',
                  onTap: () {
                    setState(() {
                      _selectedExperience = 'intermediate';
                    });
                  },
                ),
                _buildOptionCard(
                  value: 'advanced',
                  title: 'survey_experience_advanced'.tr(),
                  icon: Icons.psychology,
                  isSelected: _selectedExperience == 'advanced',
                  onTap: () {
                    setState(() {
                      _selectedExperience = 'advanced';
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStylePage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'survey_style_title'.tr(),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: [
                _buildOptionCard(
                  value: 'short',
                  title: 'survey_style_short'.tr(),
                  icon: Icons.timer,
                  isSelected: _selectedStyle == 'short',
                  onTap: () {
                    setState(() {
                      _selectedStyle = 'short';
                    });
                  },
                ),
                _buildOptionCard(
                  value: 'long',
                  title: 'survey_style_long'.tr(),
                  icon: Icons.hourglass_full,
                  isSelected: _selectedStyle == 'long',
                  onTap: () {
                    setState(() {
                      _selectedStyle = 'long';
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String value,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    if (_currentPage == 0 && _selectedGoal != null) return true;
    if (_currentPage == 1 && _selectedExperience != null) return true;
    if (_currentPage == 2 && _selectedStyle != null) return true;
    return false;
  }
}
