import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class PlanRecommendationScreen extends StatefulWidget {
  const PlanRecommendationScreen({super.key});

  @override
  State<PlanRecommendationScreen> createState() => _PlanRecommendationScreenState();
}

class _PlanRecommendationScreenState extends State<PlanRecommendationScreen> {
  String? _selectedPlan;

  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'breathing',
      'title': 'training_breathing_title',
      'description': 'training_breathing_description',
      'duration': 'training_breathing_duration',
      'features': [
        'training_breathing_feature_1',
        'training_breathing_feature_2',
        'training_breathing_feature_3',
      ],
      'color': const Color(0xFF6B73FF),
      'icon': Icons.air,
    },
    {
      'id': 'focus',
      'title': 'training_focus_title',
      'description': 'training_focus_description',
      'duration': 'training_focus_duration',
      'features': [
        'training_focus_feature_1',
        'training_focus_feature_2',
        'training_focus_feature_3',
      ],
      'color': const Color(0xFF00D9FF),
      'icon': Icons.center_focus_strong,
      'recommended': true,
    },
    {
      'id': 'emotion',
      'title': 'training_emotion_title',
      'description': 'training_emotion_description',
      'duration': 'training_emotion_duration',
      'features': [
        'training_emotion_feature_1',
        'training_emotion_feature_2',
        'training_emotion_feature_3',
      ],
      'color': const Color(0xFFFF6B6B),
      'icon': Icons.favorite,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'training_recommendation_title'.tr(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'training_recommendation_subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // 플랜 리스트
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _plans.length,
                itemBuilder: (context, index) {
                  final plan = _plans[index];
                  final isRecommended = plan['recommended'] ?? false;
                  final isSelected = _selectedPlan == plan['id'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlan = plan['id'];
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? plan['color'].withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? plan['color']
                              : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // 추천 배지
                          if (isRecommended)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFFFD700),
                                      const Color(0xFFFFA500),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  'plan_recommended'.tr(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          // 플랜 내용
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: plan['color'].withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        plan['icon'],
                                        color: plan['color'],
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            plan['title'].toString().tr(),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            plan['duration'].toString().tr(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  plan['description'].toString().tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...List.generate(
                                  (plan['features'] as List).length,
                                  (featureIndex) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: plan['color'],
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            plan['features'][featureIndex].toString().tr(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // 다음 버튼
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedPlan != null
                      ? () {
                          context.go('/notification-settings');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B73FF),
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'next'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}