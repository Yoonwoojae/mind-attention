import 'package:flutter/material.dart';
import '../../../core/utils/translation_utils.dart';
import '../../../core/utils/logger.dart';
import 'completion_screen.dart';

class ReflectionTemplate extends StatefulWidget {
  final String moduleId;
  final String sessionId;
  final Map<String, dynamic> reflectionData;
  final VoidCallback onComplete;

  const ReflectionTemplate({
    super.key,
    required this.moduleId,
    required this.sessionId,
    required this.reflectionData,
    required this.onComplete,
  });

  @override
  State<ReflectionTemplate> createState() => _ReflectionTemplateState();
}

class _ReflectionTemplateState extends State<ReflectionTemplate> {
  final Map<String, dynamic> _responses = {};
  final Map<String, TextEditingController> _textControllers = {};
  bool _isSubmitting = false;
  bool _hasChanges = false;
  int _currentQuestionIndex = 0;
  bool _showCelebration = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _autoSaveSetup();
    AppLogger.d('ReflectionTemplate initialized for module: ${widget.moduleId}, session: ${widget.sessionId}');
  }

  void _initializeControllers() {
    final questions = widget.reflectionData['questions'] ?? [];
    for (var question in questions) {
      if (question['type'] == 'text' || question['type'] == 'textarea') {
        _textControllers[question['id']] = TextEditingController();
        _textControllers[question['id']]!.addListener(() {
          _responses[question['id']] = _textControllers[question['id']]!.text;
          _hasChanges = true;
        });
      }
    }
  }

  void _autoSaveSetup() {
    // 자동 저장 기능 - 3초마다 체크
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (_hasChanges && mounted) {
        _autoSave();
        _hasChanges = false;
      }
      return mounted;
    });
  }

  void _autoSave() {
    // 자동 저장 로직
    AppLogger.d('Auto-saving reflection responses...');
    // TODO: 실제 저장 로직 구현
  }

  @override
  void dispose() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool get _isFormValid {
    final questions = widget.reflectionData['questions'] ?? [];
    for (var question in questions) {
      if (question['required'] == true) {
        final response = _responses[question['id']];
        if (response == null || (response is String && response.isEmpty)) {
          return false;
        }
      }
    }
    return true;
  }

  bool _canProceedToNext(Map<String, dynamic> question) {
    if (question['required'] == true) {
      final response = _responses[question['id']];
      return response != null && (response is! String || response.isNotEmpty);
    }
    return true; // 필수가 아니면 언제든 진행 가능
  }

  void _goToNextQuestion() async {
    final questions = widget.reflectionData['questions'] ?? [];
    
    // 성취감 애니메이션 표시
    setState(() {
      _showCelebration = true;
    });

    // 짧은 축하 애니메이션
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() {
      _showCelebration = false;
    });

    // 마지막 질문이면 제출
    if (_currentQuestionIndex >= questions.length - 1) {
      await _submitReflection();
    } else {
      // 다음 질문으로 이동
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitReflection() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('please_complete_required_fields')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // 저장 시뮬레이션
    await Future.delayed(const Duration(seconds: 1));
    
    AppLogger.i('Reflection submitted: $_responses');
    
    if (mounted) {
      // 완료 타입 결정
      final completionType = _determineCompletionType();
      
      // 완료 화면으로 이동
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => CompletionScreen(
            type: completionType,
            onContinue: () {
              // 완료 화면에서 목록 화면으로 이동
              Navigator.of(context).pop(); // 완료 화면 닫기
              Navigator.of(context).pop(); // 리플렉션 화면 닫기
              widget.onComplete(); // 원래 콜백 호출
            },
          ),
        ),
      );
    }
  }

  CompletionType _determineCompletionType() {
    final questions = widget.reflectionData['questions'] ?? [];
    final totalQuestions = questions.length;
    int answeredQuestions = 0;
    int requiredAnswered = 0;
    int totalRequired = 0;
    bool hasNegativeResponses = false;
    
    // 응답 분석
    for (var question in questions) {
      final response = _responses[question['id']];
      final isRequired = question['required'] ?? false;
      
      if (isRequired) {
        totalRequired++;
        if (response != null && (response is! String || response.isNotEmpty)) {
          requiredAnswered++;
        }
      }
      
      if (response != null && (response is! String || response.isNotEmpty)) {
        answeredQuestions++;
        
        // 부정적인 응답 체크 (스케일이 낮거나 부정적인 텍스트)
        if (response is int && response <= 2) {
          hasNegativeResponses = true;
        } else if (response is String && 
                   (response.contains('어려') || response.contains('힘들') || 
                    response.contains('못하겠') || response.contains('안되'))) {
          hasNegativeResponses = true;
        }
      }
    }
    
    final completionRate = answeredQuestions / totalQuestions;
    final requiredCompletionRate = totalRequired > 0 ? requiredAnswered / totalRequired : 1.0;
    
    // 완료 타입 결정 로직
    if (requiredCompletionRate >= 1.0 && completionRate >= 0.9) {
      return CompletionType.perfect; // 완벽해요
    } else if (requiredCompletionRate >= 1.0 && completionRate >= 0.7) {
      return CompletionType.great; // 잘했어요
    } else if (hasNegativeResponses || completionRate < 0.5) {
      return CompletionType.enough; // 이미 충분해요
    } else {
      return CompletionType.encourage; // 괜찮아요/수고했어요
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.reflectionData['title'] ?? tr('reflection_title');
    final description = widget.reflectionData['description'] ?? '';
    final questions = widget.reflectionData['questions'] ?? [];

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(tr('no_questions_available'))),
      );
    }

    final currentQuestion = questions[_currentQuestionIndex];
    final totalQuestions = questions.length;
    final progress = (_currentQuestionIndex + 1) / totalQuestions;
    final isLastQuestion = _currentQuestionIndex == totalQuestions - 1;
    final canProceed = _canProceedToNext(currentQuestion);

    return GestureDetector(
      onTap: () {
        // 키보드 외부를 탭하면 키보드 닫기
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // 진행률 바
                _buildProgressBar(progress, _currentQuestionIndex + 1, totalQuestions),
                
                // 설명 섹션 (첫 번째 질문일 때만)
                if (_currentQuestionIndex == 0 && description.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // 현재 질문
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildQuestionWidget(currentQuestion),
                  ),
                ),
                
                // 하단 네비게이션 버튼들
                _buildNavigationButtons(isLastQuestion, canProceed),
              ],
            ),
            
            // 축하 애니메이션
            if (_showCelebration)
              _buildCelebrationOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, int current, int total) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tr('question_progress'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$current/$total',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D6A4F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D6A4F)),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isLastQuestion, bool canProceed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 이전 버튼
              if (_currentQuestionIndex > 0)
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _goToPreviousQuestion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2D6A4F),
                      side: const BorderSide(color: Color(0xFF2D6A4F)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      tr('previous'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              
              if (_currentQuestionIndex > 0) const SizedBox(width: 12),
              
              // 다음/완료 버튼
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: canProceed ? _goToNextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canProceed 
                        ? const Color(0xFF2D6A4F)
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          isLastQuestion ? tr('complete_reflection') : tr('next'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D6A4F).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 40,
                  color: Color(0xFF2D6A4F),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                tr('great_job'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                tr('question_completed'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question) {
    final type = question['type'] ?? 'scale';
    final isRequired = question['required'] ?? false;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 질문 제목
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  question['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                    height: 1.3,
                  ),
                ),
              ),
              if (isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tr('required'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          if (question['description'] != null) ...[
            const SizedBox(height: 12),
            Text(
              question['description'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // 입력 위젯
          if (type == 'scale')
            _buildScaleInput(question)
          else if (type == 'radio')
            _buildRadioInput(question)
          else if (type == 'checkbox')
            _buildCheckboxInput(question)
          else if (type == 'text')
            _buildTextInput(question)
          else if (type == 'textarea')
            _buildTextAreaInput(question)
          else if (type == 'slider')
            _buildSliderInput(question),
        ],
      ),
    );
  }

  Widget _buildScaleInput(Map<String, dynamic> question) {
    final min = question['min'] ?? 1;
    final max = question['max'] ?? 5;
    final labels = question['labels'] ?? {};
    final currentValue = _responses[question['id']];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (labels['min'] != null)
              Text(
                labels['min'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            if (labels['max'] != null)
              Text(
                labels['max'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(max - min + 1, (index) {
            final value = min + index;
            final isSelected = currentValue == value;
            
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _responses[question['id']] = value;
                      _hasChanges = true;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2D6A4F)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2D6A4F)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRadioInput(Map<String, dynamic> question) {
    final options = question['options'] ?? [];
    final currentValue = _responses[question['id']];

    return Column(
      children: options.map<Widget>((option) {
        final isSelected = currentValue == option;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _responses[question['id']] = option;
                _hasChanges = true;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2D6A4F).withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2D6A4F)
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2D6A4F)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF2D6A4F),
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        color: isSelected
                            ? const Color(0xFF2C3E50)
                            : Colors.grey[700],
                        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCheckboxInput(Map<String, dynamic> question) {
    final options = question['options'] ?? [];
    final currentValues = _responses[question['id']] ?? <String>[];

    return Column(
      children: options.map<Widget>((option) {
        final isChecked = (currentValues as List).contains(option);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                final values = List<String>.from(currentValues);
                if (isChecked) {
                  values.remove(option);
                } else {
                  values.add(option);
                }
                _responses[question['id']] = values;
                _hasChanges = true;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isChecked
                    ? const Color(0xFF2D6A4F).withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isChecked
                      ? const Color(0xFF2D6A4F)
                      : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: isChecked
                          ? const Color(0xFF2D6A4F)
                          : Colors.transparent,
                      border: Border.all(
                        color: isChecked
                            ? const Color(0xFF2D6A4F)
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isChecked
                        ? const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        color: isChecked
                            ? const Color(0xFF2C3E50)
                            : Colors.grey[700],
                        fontWeight: isChecked ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(Map<String, dynamic> question) {
    return TextField(
      controller: _textControllers[question['id']],
      decoration: InputDecoration(
        hintText: question['placeholder'] ?? tr('enter_your_answer'),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D6A4F), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildTextAreaInput(Map<String, dynamic> question) {
    return TextField(
      controller: _textControllers[question['id']],
      maxLines: 5,
      decoration: InputDecoration(
        hintText: question['placeholder'] ?? tr('enter_your_thoughts'),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D6A4F), width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: const TextStyle(
        fontSize: 15,
        color: Color(0xFF2C3E50),
        height: 1.5,
      ),
    );
  }

  Widget _buildSliderInput(Map<String, dynamic> question) {
    final min = (question['min'] ?? 0).toDouble();
    final max = (question['max'] ?? 100).toDouble();
    final divisions = question['divisions'] ?? 10;
    final currentValue = (_responses[question['id']] ?? min).toDouble();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${min.toInt()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2D6A4F).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${currentValue.toInt()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D6A4F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '${max.toInt()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Slider(
          value: currentValue,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: const Color(0xFF2D6A4F),
          inactiveColor: Colors.grey.shade300,
          onChanged: (value) {
            setState(() {
              _responses[question['id']] = value;
              _hasChanges = true;
            });
          },
        ),
      ],
    );
  }
}