import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/logger.dart';
import '../../core/constants/app_colors.dart';

class DailyFocusScreen extends StatefulWidget {
  const DailyFocusScreen({super.key});

  @override
  State<DailyFocusScreen> createState() => _DailyFocusScreenState();
}

class _DailyFocusScreenState extends State<DailyFocusScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _focusController = TextEditingController();
  
  int _currentStep = 0;
  TimeOfDay? _startReminder;
  TimeOfDay? _endReminder;
  bool _canContinue = false;
  
  // 저장된 데이터 (실제로는 서비스에서 관리)
  static String? savedFocus;
  static TimeOfDay? savedStartReminder;
  static TimeOfDay? savedEndReminder;

  @override
  void initState() {
    super.initState();
    _focusController.addListener(() {
      setState(() {
        _canContinue = _focusController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveFocus() {
    savedFocus = _focusController.text;
    savedStartReminder = _startReminder;
    savedEndReminder = _endReminder;
    
    AppLogger.i('Daily focus saved: $savedFocus');
    if (_startReminder != null) {
      AppLogger.i('Start reminder: ${_startReminder!.format(context)}');
    }
    if (_endReminder != null) {
      AppLogger.i('End reminder: ${_endReminder!.format(context)}');
    }
    
    // 저장 후 완료 화면으로
    _nextStep();
  }

  void _resetFocus() {
    savedFocus = null;
    savedStartReminder = null;
    savedEndReminder = null;
    _focusController.clear();
    _startReminder = null;
    _endReminder = null;
    _currentStep = 0;
    _pageController.jumpToPage(0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // 이미 설정되어 있으면 완료 화면 표시
    if (savedFocus != null && _currentStep == 0) {
      return _buildCompletedScreen();
    }

    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Daily Focus',
            style: TextStyle(
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Column(
        children: [
          // Progress Indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: index <= _currentStep 
                            ? AppColors.primary 
                            : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: index < _currentStep
                            ? const Icon(Icons.check, color: Colors.white, size: 20)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: index <= _currentStep 
                                    ? Colors.white 
                                    : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStepTitle(index),
                        style: TextStyle(
                          fontSize: 12,
                          color: index <= _currentStep 
                            ? AppColors.primary 
                            : Colors.grey[600],
                          fontWeight: index == _currentStep 
                            ? FontWeight.w600 
                            : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
        ],
      ),
      ),
    ),
    );
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Set Focus';
      case 1:
        return 'Set Reminders';
      case 2:
        return 'Complete';
      default:
        return '';
    }
  }

  // Step 1: 목표 입력
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.center_focus_strong,
                size: 50,
                color: Color(0xFFFF9800),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "What's your focus today?",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set a clear intention for what you want to accomplish today',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          TextField(
            controller: _focusController,
            maxLength: 90,
            decoration: InputDecoration(
              hintText: 'e.g., Complete the project proposal',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _canContinue ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Step 2: 알림 설정
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active,
                size: 50,
                color: Colors.blue[600],
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Set reminders',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get notified to start and finish your focused work',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 30),
          
          // Start Reminder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.alarm, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Text(
                      'Start Reminder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _startReminder != null,
                      onChanged: (value) async {
                        if (value) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              _startReminder = time;
                            });
                          }
                        } else {
                          setState(() {
                            _startReminder = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
                if (_startReminder != null) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _startReminder!,
                      );
                      if (time != null) {
                        setState(() {
                          _startReminder = time;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _startReminder!.format(context),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // End Reminder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.alarm_off, color: AppColors.primary),
                    const SizedBox(width: 12),
                    const Text(
                      'End Reminder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _endReminder != null,
                      onChanged: (value) async {
                        if (value) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              _endReminder = time;
                            });
                          }
                        } else {
                          setState(() {
                            _endReminder = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
                if (_endReminder != null) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: _endReminder!,
                      );
                      if (time != null) {
                        setState(() {
                          _endReminder = time;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            _endReminder!.format(context),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _previousStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(double.infinity, 52),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveFocus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16, 
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Step 3: 완료
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'All set!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your daily focus has been set',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          
          // Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.flag,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Today's Focus",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  savedFocus ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (savedStartReminder != null || savedEndReminder != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  if (savedStartReminder != null)
                    Row(
                      children: [
                        Icon(Icons.alarm, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Start at ${savedStartReminder is TimeOfDay ? savedStartReminder!.format(context) : savedStartReminder.toString()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  if (savedEndReminder != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.alarm_off, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'End at ${savedEndReminder is TimeOfDay ? savedEndReminder!.format(context) : savedEndReminder.toString()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Done',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 이미 설정된 경우 표시되는 화면
  Widget _buildCompletedScreen() {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3436)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Daily Focus',
            style: TextStyle(
              color: Color(0xFF2D3436),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: _resetFocus,
              child: const Text(
                'Edit',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF66D9EF).withOpacity(0.8),
                    const Color(0xFF4AA3BA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF66D9EF).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.flag,
                          size: 24,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Today's Focus",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    savedFocus ?? '',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            if (savedStartReminder != null || savedEndReminder != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reminders',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (savedStartReminder != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.alarm, color: Colors.green[700]),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start working',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  savedStartReminder is TimeOfDay 
                                    ? savedStartReminder!.format(context)
                                    : savedStartReminder.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (savedEndReminder != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.alarm_off, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stop working',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange[900],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  savedEndReminder is TimeOfDay
                                    ? savedEndReminder!.format(context)
                                    : savedEndReminder.toString(),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            
            // Tips
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Focus Tip',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[900],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Eliminate distractions and take regular breaks to maintain your focus throughout the day.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber[800],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}