import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_attention/core/utils/translation_utils.dart';
import 'package:mind_attention/core/utils/logger.dart';
import 'package:mind_attention/widgets/help_dialog.dart';

class TaskBreakdownScreen extends StatefulWidget {
  const TaskBreakdownScreen({super.key});

  @override
  State<TaskBreakdownScreen> createState() => _TaskBreakdownScreenState();
}

class _TaskBreakdownScreenState extends State<TaskBreakdownScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _taskController = TextEditingController();
  final List<TaskStep> _steps = [];
  TaskStep? _currentStep;
  int _currentStepIndex = 0;
  bool _isBreakingDown = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _breakDownTask() async {
    if (_taskController.text.isEmpty) return;

    setState(() {
      _isBreakingDown = true;
    });

    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(seconds: 1));

    final taskText = _taskController.text;
    final steps = _generateSteps(taskText);

    setState(() {
      _steps.clear();
      _steps.addAll(steps);
      _currentStepIndex = 0;
      if (_steps.isNotEmpty) {
        _currentStep = _steps[0];
      }
      _isBreakingDown = false;
    });

    _animationController.forward();
    AppLogger.i('Task broken down into ${_steps.length} steps');
  }

  List<TaskStep> _generateSteps(String task) {
    final lowerTask = task.toLowerCase();
    
    if (lowerTask.contains('email') || lowerTask.contains('이메일')) {
      return [
        TaskStep(title: tr('task_email_open'), minutes: 3),
        TaskStep(title: tr('task_email_read'), minutes: 5),
        TaskStep(title: tr('task_email_draft'), minutes: 10),
        TaskStep(title: tr('task_email_review'), minutes: 3),
        TaskStep(title: tr('task_email_send'), minutes: 2),
      ];
    } else if (lowerTask.contains('report') || lowerTask.contains('보고서')) {
      return [
        TaskStep(title: tr('task_report_outline'), minutes: 10),
        TaskStep(title: tr('task_report_intro'), minutes: 15),
        TaskStep(title: tr('task_report_main'), minutes: 20),
        TaskStep(title: tr('task_report_conclusion'), minutes: 10),
        TaskStep(title: tr('task_report_review'), minutes: 5),
      ];
    } else if (lowerTask.contains('clean') || lowerTask.contains('청소')) {
      return [
        TaskStep(title: tr('task_clean_pickup'), minutes: 5),
        TaskStep(title: tr('task_clean_desk'), minutes: 5),
        TaskStep(title: tr('task_clean_organize'), minutes: 10),
        TaskStep(title: tr('task_clean_trash'), minutes: 3),
      ];
    } else {
      return [
        TaskStep(title: tr('task_generic_prepare'), minutes: 5),
        TaskStep(title: tr('task_generic_start'), minutes: 10),
        TaskStep(title: tr('task_generic_continue'), minutes: 15),
        TaskStep(title: tr('task_generic_finish'), minutes: 10),
        TaskStep(title: tr('task_generic_review'), minutes: 5),
      ];
    }
  }

  void _completeCurrentStep() {
    if (_currentStep == null) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _currentStep!.isCompleted = true;
      
      if (_currentStepIndex < _steps.length - 1) {
        _currentStepIndex++;
        _currentStep = _steps[_currentStepIndex];
        _animationController.reset();
        _animationController.forward();
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _skipCurrentStep() {
    if (_currentStep == null) return;

    HapticFeedback.lightImpact();

    setState(() {
      _currentStep!.isSkipped = true;
      
      if (_currentStepIndex < _steps.length - 1) {
        _currentStepIndex++;
        _currentStep = _steps[_currentStepIndex];
        _animationController.reset();
        _animationController.forward();
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _breakDownFurther() {
    if (_currentStep == null) return;

    // 이미 너무 작은 작업은 더 이상 분할하지 않음
    if (_currentStep!.minutes <= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('task_cannot_break_smaller')),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // 전체 스텝이 너무 많으면 제한
    if (_steps.length >= 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('task_too_many_steps')),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    HapticFeedback.lightImpact();

    final subSteps = [
      TaskStep(
        title: '${_currentStep!.title} - ${tr('task_substep_1')}',
        minutes: (_currentStep!.minutes / 3).round().clamp(1, 999),
      ),
      TaskStep(
        title: '${_currentStep!.title} - ${tr('task_substep_2')}',
        minutes: (_currentStep!.minutes / 3).round().clamp(1, 999),
      ),
      TaskStep(
        title: '${_currentStep!.title} - ${tr('task_substep_3')}',
        minutes: (_currentStep!.minutes / 3).round().clamp(1, 999),
      ),
    ];

    setState(() {
      _steps.removeAt(_currentStepIndex);
      _steps.insertAll(_currentStepIndex, subSteps);
      _currentStep = _steps[_currentStepIndex];
    });
    
    AppLogger.i('Task broken down further. Total steps: ${_steps.length}');
  }

  void _showCompletionDialog() {
    final completedCount = _steps.where((s) => s.isCompleted).length;
    final skippedCount = _steps.where((s) => s.isSkipped).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.task_alt,
              color: Color(0xFF2196F3),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              tr('task_all_completed'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${tr('task_completed_count')}: $completedCount\n${tr('task_skipped_count')}: $skippedCount',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _resetTask();
              },
              child: Text(tr('task_new')),
            ),
          ],
        ),
      ),
    );
  }

  void _resetTask() {
    setState(() {
      _taskController.clear();
      _steps.clear();
      _currentStep = null;
      _currentStepIndex = 0;
    });
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Text(
          tr('focus_task_breakdown'),
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {
              HelpDialog.show(
                context,
                titleKey: 'help_task_breakdown_title',
                purposeKey: 'help_task_breakdown_purpose',
                benefitsKey: 'help_task_breakdown_benefits',
                howToUseKey: 'help_task_breakdown_how_to_use',
                tipKeys: [
                  'help_task_breakdown_tip1',
                  'help_task_breakdown_tip2',
                  'help_task_breakdown_tip3',
                ],
                primaryColor: const Color(0xFF2196F3),
              );
            },
          ),
          if (_steps.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentStepIndex + 1}/${_steps.length}',
                style: const TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _currentStep == null
            ? _buildTaskInputView()
            : _buildCurrentStepView(),
      ),
      ),
    );
  }

  Widget _buildTaskInputView() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            tr('task_whats_your_task'),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr('task_breakdown_hint'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _taskController,
              maxLines: 3,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: tr('task_input_placeholder'),
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              onSubmitted: (_) => _breakDownTask(),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: _isBreakingDown ? null : _breakDownTask,
              child: _isBreakingDown
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          tr('task_break_down'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 40),
          _buildTemplates(),
        ],
        ),
      ),
    );
  }

  Widget _buildTemplates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('task_templates'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTemplateChip(tr('task_template_email')),
            _buildTemplateChip(tr('task_template_report')),
            _buildTemplateChip(tr('task_template_clean')),
            _buildTemplateChip(tr('task_template_shopping')),
          ],
        ),
      ],
    );
  }

  Widget _buildTemplateChip(String label) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        _taskController.text = label;
        _breakDownTask();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildProgressIndicator(),
                const SizedBox(height: 40),
                _buildCurrentStepCard(),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 40),
                _buildStepsList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final completedSteps = _steps.where((s) => s.isCompleted || s.isSkipped).length;
    final progress = _steps.isEmpty ? 0.0 : completedSteps / _steps.length;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).round()}% ${tr('task_progress')}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepCard() {
    if (_currentStep == null) return const SizedBox();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.9 + (_animationController.value * 0.1),
          child: Opacity(
            opacity: 0.5 + (_animationController.value * 0.5),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tr('task_current_focus'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _currentStep!.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 20,
                          color: Color(0xFF2196F3),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_currentStep!.minutes} ${tr('focus_timer_minutes')}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2196F3),
                            fontWeight: FontWeight.w600,
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
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                onTap: _completeCurrentStep,
                label: tr('task_complete'),
                color: const Color(0xFF4CAF50),
                icon: Icons.check,
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/focus/timer?duration=${_currentStep?.minutes ?? 10}');
                },
                label: tr('task_start_timer'),
                color: const Color(0xFF4CAF50),
                icon: Icons.timer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                onTap: _breakDownFurther,
                label: tr('task_break_smaller'),
                color: const Color(0xFFFF9800),
                icon: Icons.splitscreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                onTap: _skipCurrentStep,
                label: tr('task_skip'),
                color: Colors.grey,
                icon: Icons.skip_next,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required String label,
    required Color color,
    required IconData icon,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isPrimary ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsList() {
    if (_steps.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('task_all_steps'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...(_steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isCurrent = index == _currentStepIndex;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrent
                  ? const Color(0xFF2196F3).withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrent
                    ? const Color(0xFF2196F3)
                    : Colors.grey.shade300,
                width: isCurrent ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: step.isCompleted
                        ? const Color(0xFF4CAF50)
                        : step.isSkipped
                            ? Colors.grey
                            : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.isCompleted
                          ? const Color(0xFF4CAF50)
                          : step.isSkipped
                              ? Colors.grey
                              : Colors.grey.shade400,
                    ),
                  ),
                  child: step.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : step.isSkipped
                          ? const Icon(Icons.close, size: 16, color: Colors.white)
                          : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 14,
                      color: step.isCompleted || step.isSkipped
                          ? Colors.grey
                          : Colors.black87,
                      decoration: step.isCompleted || step.isSkipped
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                Text(
                  '${step.minutes}${tr('task_min')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        })),
      ],
    );
  }
}

class TaskStep {
  final String title;
  final int minutes;
  bool isCompleted;
  bool isSkipped;

  TaskStep({
    required this.title,
    required this.minutes,
    this.isCompleted = false,
    this.isSkipped = false,
  });
}