import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlan = 'yearly';
  final PageController _reviewController = PageController();

  final List<Map<String, String>> _reviews = [
    {
      'name': 'review_name_1',
      'rating': '5',
      'text': 'review_text_1',
      'date': 'review_date_1',
    },
    {
      'name': 'review_name_2',
      'rating': '5',
      'text': 'review_text_2',
      'date': 'review_date_2',
    },
    {
      'name': 'review_name_3',
      'rating': '5',
      'text': 'review_text_3',
      'date': 'review_date_3',
    },
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 헤더
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6B73FF).withOpacity(0.1),
                            const Color(0xFF000DFF).withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        children: [
                          // 7일 무료 배지
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFFD700).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.celebration, color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'subscription_free_trial'.tr(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'subscription_title'.tr(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'subscription_subtitle'.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 구독 플랜
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // 연간 플랜
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPlan = 'yearly';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _selectedPlan == 'yearly'
                                    ? const Color(0xFF6B73FF).withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedPlan == 'yearly'
                                      ? const Color(0xFF6B73FF)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: _selectedPlan == 'yearly'
                                                ? const Color(0xFF6B73FF)
                                                : Colors.grey[400]!,
                                            width: 2,
                                          ),
                                        ),
                                        child: _selectedPlan == 'yearly'
                                            ? Container(
                                                margin: const EdgeInsets.all(4),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF6B73FF),
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'subscription_yearly_title'.tr(),
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    'subscription_save_badge'.tr(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'subscription_yearly_price'.tr(),
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
                                  if (_selectedPlan == 'yearly') ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'subscription_yearly_benefit'.tr(),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.green[700],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 월간 플랜
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPlan = 'monthly';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: _selectedPlan == 'monthly'
                                    ? const Color(0xFF6B73FF).withOpacity(0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _selectedPlan == 'monthly'
                                      ? const Color(0xFF6B73FF)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: _selectedPlan == 'monthly'
                                            ? const Color(0xFF6B73FF)
                                            : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                    ),
                                    child: _selectedPlan == 'monthly'
                                        ? Container(
                                            margin: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF6B73FF),
                                              shape: BoxShape.circle,
                                            ),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'subscription_monthly_title'.tr(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'subscription_monthly_price'.tr(),
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
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 사용자 리뷰
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'subscription_reviews_title'.tr(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 140,
                            child: PageView.builder(
                              controller: _reviewController,
                              itemCount: _reviews.length,
                              itemBuilder: (context, index) {
                                final review = _reviews[index];
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            review['name']!.tr(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          ...List.generate(
                                            int.parse(review['rating']!),
                                            (index) => const Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: Text(
                                          review['text']!.tr(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            height: 1.4,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        review['date']!.tr(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // 결제 버튼
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'subscription_trial_info'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // 결제 프로세스 (구글 플레이 결제)
                        // 실제로는 결제 완료 후 이동
                        context.go('/user-customization');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B73FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'subscription_start_trial'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
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
  }
}