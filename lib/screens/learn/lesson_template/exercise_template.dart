import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/utils/translation_utils.dart';
import '../../../core/utils/logger.dart';

class ExerciseTemplate extends StatefulWidget {
  final String moduleId;
  final String sessionId;
  final Map<String, dynamic> exerciseData;
  final VoidCallback onComplete;

  const ExerciseTemplate({
    super.key,
    required this.moduleId,
    required this.sessionId,
    required this.exerciseData,
    required this.onComplete,
  });

  @override
  State<ExerciseTemplate> createState() => _ExerciseTemplateState();
}

class _ExerciseTemplateState extends State<ExerciseTemplate> with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  Map<int, dynamic> _userAnswers = {};
  bool _showFeedback = false;
  bool _isCompleted = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _resultAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.elasticOut,
    ));
    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
    
    AppLogger.d('ExerciseTemplate initialized for module: ${widget.moduleId}, session: ${widget.sessionId}');
  }

  @override
  void dispose() {
    _animationController.dispose();
    _resultAnimationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get questions => widget.exerciseData['questions'] ?? [];
  
  Map<String, dynamic> get currentQuestion => 
    questions.isNotEmpty && _currentQuestionIndex < questions.length
      ? questions[_currentQuestionIndex]
      : {};

  void _selectAnswer(dynamic answer) {
    if (_showFeedback) return;
    
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
      _showFeedback = true;
      
      // 정답 체크
      final isCorrect = currentQuestion['correctAnswer'] == answer || 
          (currentQuestion['type'] == 'matching' && _checkMatchingAnswer(answer));
      
      if (isCorrect) {
        _correctAnswers++;
      }
    });
    
    // 결과 팝업 표시
    _showResultDialog();
  }
  
  void _showResultDialog() {
    final userAnswer = _userAnswers[_currentQuestionIndex];
    final correctAnswer = currentQuestion['correctAnswer'];
    final isCorrect = userAnswer == correctAnswer;
    final type = currentQuestion['type'] ?? 'multiple_choice';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        _resultAnimationController.forward();
        
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _resultAnimationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 아이콘 애니메이션
                      Transform.rotate(
                        angle: isCorrect ? 0 : _rotateAnimation.value * 0.1,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            size: 50,
                            color: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // 결과 텍스트
                      Text(
                        isCorrect ? tr('correct_answer_title') : tr('incorrect_answer_title'),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 사용자 답변과 정답 표시
                      if (!isCorrect) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              // 사용자 답변
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.red.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tr('your_answer'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getAnswerText(userAnswer, type),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.red.shade700,
                                            decoration: TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(height: 1),
                              const SizedBox(height: 12),
                              // 정답
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.check,
                                    size: 20,
                                    color: Colors.green.shade600,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tr('correct_answer'),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getAnswerText(correctAnswer, type),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.green.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // 설명 섹션
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green.shade50 : Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCorrect ? Colors.green.shade200 : Colors.blue.shade200,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  size: 18,
                                  color: isCorrect ? Colors.green.shade700 : Colors.blue.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  tr('explanation'),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isCorrect ? Colors.green.shade700 : Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentQuestion['explanation'] ?? 
                              (isCorrect 
                                  ? (currentQuestion['correctFeedback'] ?? tr('correct_answer_feedback'))
                                  : (currentQuestion['incorrectFeedback'] ?? tr('incorrect_answer_feedback'))),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // 확인 버튼
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _nextQuestion();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D6A4F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        child: Text(
                          tr('continue_button'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    ).then((_) {
      _resultAnimationController.reset();
    });
  }
  
  String _getAnswerText(dynamic answer, String type) {
    if (answer == null) return '';
    
    switch (type) {
      case 'true_false':
        return answer == true ? tr('true') : tr('false');
      case 'situation':
        final situations = currentQuestion['situations'] ?? [];
        try {
          final situation = situations.firstWhere((s) => s['id'] == answer);
          return situation['title'] ?? answer.toString();
        } catch (e) {
          // 일치하는 상황을 찾지 못한 경우
          return answer.toString();
        }
      default:
        return answer.toString();
    }
  }
  
  bool _checkMatchingAnswer(Map<String, String> userMatches) {
    final correctMatches = currentQuestion['correctMatches'] as Map<String, String>?;
    if (correctMatches == null) return false;
    
    for (final key in correctMatches.keys) {
      if (userMatches[key] != correctMatches[key]) {
        return false;
      }
    }
    return true;
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      _animationController.reverse().then((_) {
        setState(() {
          _currentQuestionIndex++;
          _showFeedback = false;
        });
        _animationController.forward();
      });
    } else {
      setState(() {
        _isCompleted = true;
      });
    }
  }
  
  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _animationController.reverse().then((_) {
        setState(() {
          _currentQuestionIndex--;
          _showFeedback = false;
        });
        _animationController.forward();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildCompletionScreen();
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (_currentQuestionIndex > 0) {
              // 이전 문제로 돌아가기
              _previousQuestion();
            } else {
              // 첫 번째 문제에서는 목록으로
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          widget.exerciseData['title'] ?? tr('exercise_title'),
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
              // 진행도 표시
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr('question_progress', args: {
                            'current': '${_currentQuestionIndex + 1}',
                            'total': '${questions.length}'
                          }),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D6A4F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Color(0xFF2D6A4F),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$_correctAnswers',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF2D6A4F),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentQuestionIndex + 1) / questions.length,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D6A4F)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 문제 영역
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildQuestionContent(),
                ),
              ),
            ],
          ),
          
          // 하단 고정 버튼 (피드백 표시 중일 때만)
          if (_showFeedback)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
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
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D6A4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: Text(
                        _currentQuestionIndex < questions.length - 1 
                            ? tr('next_question')
                            : tr('complete_exercise'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent() {
    final type = currentQuestion['type'] ?? 'multiple_choice';
    
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 20, 20, _showFeedback ? 100 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 문제 텍스트
          Container(
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
                if (currentQuestion['context'] != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentQuestion['context'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade900,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  currentQuestion['question'] ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 답변 옵션들
          if (type == 'multiple_choice')
            _buildMultipleChoiceOptions()
          else if (type == 'true_false')
            _buildTrueFalseOptions()
          else if (type == 'matching')
            _buildMatchingOptions()
          else if (type == 'situation')
            _buildSituationOptions(),
            
          // 피드백 표시
          if (_showFeedback)
            _buildFeedback(),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceOptions() {
    final options = currentQuestion['options'] ?? [];
    final selectedAnswer = _userAnswers[_currentQuestionIndex];
    final correctAnswer = currentQuestion['correctAnswer'];
    
    return Column(
      children: options.map<Widget>((option) {
        final isSelected = selectedAnswer == option;
        final isCorrect = correctAnswer == option;
        final showAsCorrect = _showFeedback && isCorrect;
        final showAsWrong = _showFeedback && isSelected && !isCorrect;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: !_showFeedback ? () => _selectAnswer(option) : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: showAsCorrect
                    ? Colors.green.shade50
                    : showAsWrong
                        ? Colors.red.shade50
                        : isSelected
                            ? const Color(0xFF2D6A4F).withOpacity(0.1)
                            : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: showAsCorrect
                      ? Colors.green.shade400
                      : showAsWrong
                          ? Colors.red.shade400
                          : isSelected
                              ? const Color(0xFF2D6A4F)
                              : Colors.grey.shade300,
                  width: showAsCorrect || showAsWrong ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: showAsCorrect
                          ? Colors.green.shade400
                          : showAsWrong
                              ? Colors.red.shade400
                              : isSelected
                                  ? const Color(0xFF2D6A4F)
                                  : Colors.transparent,
                      border: Border.all(
                        color: showAsCorrect
                            ? Colors.green.shade400
                            : showAsWrong
                                ? Colors.red.shade400
                                : isSelected
                                    ? const Color(0xFF2D6A4F)
                                    : Colors.grey.shade400,
                      ),
                    ),
                    child: showAsCorrect
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : showAsWrong
                            ? const Icon(Icons.close, size: 16, color: Colors.white)
                            : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        color: showAsCorrect
                            ? Colors.green.shade900
                            : showAsWrong
                                ? Colors.red.shade900
                                : const Color(0xFF2C3E50),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildTrueFalseOptions() {
    final selectedAnswer = _userAnswers[_currentQuestionIndex];
    final correctAnswer = currentQuestion['correctAnswer'];
    
    return Row(
      children: [
        Expanded(
          child: _buildTrueFalseButton(
            true,
            selectedAnswer == true,
            _showFeedback && correctAnswer == true,
            _showFeedback && selectedAnswer == true && correctAnswer != true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTrueFalseButton(
            false,
            selectedAnswer == false,
            _showFeedback && correctAnswer == false,
            _showFeedback && selectedAnswer == false && correctAnswer != false,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTrueFalseButton(bool value, bool isSelected, bool showAsCorrect, bool showAsWrong) {
    return InkWell(
      onTap: !_showFeedback ? () => _selectAnswer(value) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: showAsCorrect
              ? Colors.green.shade50
              : showAsWrong
                  ? Colors.red.shade50
                  : isSelected
                      ? const Color(0xFF2D6A4F).withOpacity(0.1)
                      : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: showAsCorrect
                ? Colors.green.shade400
                : showAsWrong
                    ? Colors.red.shade400
                    : isSelected
                        ? const Color(0xFF2D6A4F)
                        : Colors.grey.shade300,
            width: showAsCorrect || showAsWrong ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              value ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 40,
              color: showAsCorrect
                  ? Colors.green.shade600
                  : showAsWrong
                      ? Colors.red.shade600
                      : isSelected
                          ? const Color(0xFF2D6A4F)
                          : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              value ? tr('true') : tr('false'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: showAsCorrect
                    ? Colors.green.shade900
                    : showAsWrong
                        ? Colors.red.shade900
                        : const Color(0xFF2C3E50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchingOptions() {
    // 매칭 문제는 복잡하므로 간단한 예시만
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        tr('matching_exercise_placeholder'),
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSituationOptions() {
    final situations = currentQuestion['situations'] ?? [];
    final selectedAnswer = _userAnswers[_currentQuestionIndex];
    final correctAnswer = currentQuestion['correctAnswer'];
    
    return Column(
      children: situations.map<Widget>((situation) {
        final isSelected = selectedAnswer == situation['id'];
        final isCorrect = correctAnswer == situation['id'];
        final showAsCorrect = _showFeedback && isCorrect;
        final showAsWrong = _showFeedback && isSelected && !isCorrect;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: !_showFeedback ? () => _selectAnswer(situation['id']) : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: showAsCorrect
                    ? Colors.green.shade50
                    : showAsWrong
                        ? Colors.red.shade50
                        : isSelected
                            ? const Color(0xFF2D6A4F).withOpacity(0.1)
                            : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: showAsCorrect
                      ? Colors.green.shade400
                      : showAsWrong
                          ? Colors.red.shade400
                          : isSelected
                              ? const Color(0xFF2D6A4F)
                              : Colors.grey.shade300,
                  width: showAsCorrect || showAsWrong ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    situation['title'] ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: showAsCorrect
                          ? Colors.green.shade900
                          : showAsWrong
                              ? Colors.red.shade900
                              : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    situation['description'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: showAsCorrect
                          ? Colors.green.shade800
                          : showAsWrong
                              ? Colors.red.shade800
                              : Colors.grey[700],
                      height: 1.4,
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

  Widget _buildFeedback() {
    final userAnswer = _userAnswers[_currentQuestionIndex];
    final correctAnswer = currentQuestion['correctAnswer'];
    final isCorrect = userAnswer == correctAnswer;
    final feedback = isCorrect 
        ? currentQuestion['correctFeedback'] ?? tr('correct_answer_feedback')
        : currentQuestion['incorrectFeedback'] ?? tr('incorrect_answer_feedback');
    
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green.shade300 : Colors.orange.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect ? Icons.thumb_up : Icons.info_outline,
            size: 20,
            color: isCorrect ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feedback,
              style: TextStyle(
                fontSize: 14,
                color: isCorrect ? Colors.green.shade900 : Colors.orange.shade900,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final percentage = (_correctAnswers / questions.length * 100).round();
    final isExcellent = percentage >= 80;
    final isPerfect = percentage == 100;
    final isFailed = percentage == 0;
    
    String message;
    IconData icon;
    Color color;
    List<IconData> animatedIcons = [];
    
    if (isPerfect) {
      message = tr('perfect_score_message');
      icon = Icons.emoji_events;
      color = Colors.amber;
      animatedIcons = [Icons.star, Icons.auto_awesome, Icons.workspace_premium];
    } else if (isExcellent) {
      message = tr('excellent_score_message');
      icon = Icons.celebration;
      color = Colors.green;
      animatedIcons = [Icons.favorite, Icons.thumb_up, Icons.sentiment_very_satisfied];
    } else if (isFailed) {
      message = tr('failed_score_message');
      icon = Icons.sentiment_satisfied_alt;
      color = Colors.blue;
      animatedIcons = [Icons.favorite_border, Icons.psychology, Icons.self_improvement];
    } else if (percentage >= 50) {
      message = tr('good_score_message');
      icon = Icons.thumb_up;
      color = Colors.orange;
      animatedIcons = [Icons.emoji_emotions, Icons.volunteer_activism, Icons.local_fire_department];
    } else {
      message = tr('low_score_message');
      icon = Icons.mood;
      color = Colors.purple;
      animatedIcons = [Icons.rocket_launch, Icons.auto_fix_high, Icons.tips_and_updates];
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            // 마지막 문제로 돌아가기
            setState(() {
              _isCompleted = false;
              _currentQuestionIndex = questions.length - 1;
              _showFeedback = false;
            });
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 메인 아이콘과 주변 애니메이션 아이콘들
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // 주변 떠다니는 아이콘들
                  ...List.generate(animatedIcons.length, (index) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 2000 + index * 200),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        final angle = (index * 2 * 3.14159 / animatedIcons.length) + (value * 2 * 3.14159);
                        final radius = 80.0 + (20 * sin(value * 4 * 3.14159));
                        return Positioned(
                          left: 60 + radius * cos(angle),
                          top: 60 + radius * sin(angle),
                          child: Transform.scale(
                            scale: 0.5 + (0.5 * sin(value * 2 * 3.14159)),
                            child: Opacity(
                              opacity: 0.3 + (0.7 * sin(value * 3.14159)),
                              child: Icon(
                                animatedIcons[index],
                                size: 30,
                                color: color.withOpacity(0.6),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  
                  // 메인 아이콘 with 펄스 애니메이션
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1500),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // 펄스 효과
                          ...List.generate(3, (index) {
                            return TweenAnimationBuilder<double>(
                              duration: Duration(milliseconds: 1500 + index * 300),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOut,
                              builder: (context, pulseValue, child) {
                                return Container(
                                  width: 120 + (60 * pulseValue),
                                  height: 120 + (60 * pulseValue),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: color.withOpacity(0.3 * (1 - pulseValue)),
                                      width: 2,
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                          // 메인 아이콘 컨테이너
                          Transform.scale(
                            scale: value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color.withOpacity(0.3),
                                    color.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(seconds: 3),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.linear,
                                onEnd: () {
                                  // 애니메이션 반복
                                },
                                builder: (context, rotateValue, child) {
                                  return Transform.rotate(
                                    angle: rotateValue * 2 * 3.14159,
                                    child: Icon(
                                      icon,
                                      size: 60,
                                      color: color,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // 제목
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Text(
                        tr('exercise_completed'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              
              // 맞춤형 메시지 with 애니메이션
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 800),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const Spacer(),
              
              // 계속 버튼
              ElevatedButton(
                onPressed: widget.onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: Text(
                  tr('continue_button'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
