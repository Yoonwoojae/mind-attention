import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_attention/core/constants/app_colors.dart';

class PlanRecommendationScreen extends StatefulWidget {
  const PlanRecommendationScreen({super.key});

  @override
  State<PlanRecommendationScreen> createState() => _PlanRecommendationScreenState();
}

class _PlanRecommendationScreenState extends State<PlanRecommendationScreen> {
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
      'color': AppColors.primary,
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

                  return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
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
                  onPressed: () {
                    context.go('/notification-settings');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
