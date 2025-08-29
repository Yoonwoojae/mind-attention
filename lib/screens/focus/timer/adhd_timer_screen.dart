import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mind_attention/core/utils/translation_utils.dart';
import 'package:mind_attention/core/utils/logger.dart';
import 'package:mind_attention/widgets/help_dialog.dart';
import 'package:audioplayers/audioplayers.dart';

class ADHDTimerScreen extends StatefulWidget {
  final int? initialDuration;

  const ADHDTimerScreen({super.key, this.initialDuration});

  @override
  State<ADHDTimerScreen> createState() => _ADHDTimerScreenState();
}

class _ADHDTimerScreenState extends State<ADHDTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  Timer? _timer;
  int _selectedMinutes = 10;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  int _completedBlocks = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<int> _presetMinutes = [5, 10, 15, 20, 25];

  @override
  void initState() {
    super.initState();
    if (widget.initialDuration != null) {
      _selectedMinutes = widget.initialDuration!;
    }
    _remainingSeconds = _selectedMinutes * 60;
    
    _progressController = AnimationController(
      duration: Duration(minutes: _selectedMinutes),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingSeconds == 0) {
      _remainingSeconds = _selectedMinutes * 60;
    }

    setState(() {
      _isRunning = true;
      _isPaused = false;
    });

    HapticFeedback.mediumImpact();
    _progressController.duration = Duration(seconds: _remainingSeconds);
    _progressController.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          
          if (_remainingSeconds == 60) {
            HapticFeedback.lightImpact();
            _showNotification(tr('focus_timer_one_minute'));
          }
        } else {
          _completeTimer();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
    _timer?.cancel();
    _progressController.stop();
    HapticFeedback.lightImpact();
  }

  void _resumeTimer() {
    _startTimer();
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
    _timer?.cancel();
    _progressController.reset();
    HapticFeedback.lightImpact();
  }

  void _completeTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _completedBlocks++;
    });
    
    HapticFeedback.heavyImpact();
    _playCompletionSound();
    _showCompletionDialog();
    
    AppLogger.i('Timer completed: $_selectedMinutes minutes, Total blocks: $_completedBlocks');
  }

  void _playCompletionSound() async {
    // TODO: Add completion sound file
    // try {
    //   await _audioPlayer.play(AssetSource('sounds/completion.mp3'));
    // } catch (e) {
    //   AppLogger.e('Failed to play sound: $e');
    // }
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              color: Color(0xFF4CAF50),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              tr('focus_timer_completed'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tr('focus_timer_blocks_today').replaceAll('{count}', '$_completedBlocks'),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showBreakSuggestion();
                  },
                  child: Text(tr('focus_timer_take_break')),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _resetTimer();
                  },
                  child: Text(tr('focus_timer_start_another')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBreakSuggestion() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr('focus_timer_break_suggestion'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildBreakOption(
              Icons.local_drink,
              tr('focus_break_water'),
              Colors.blue,
            ),
            _buildBreakOption(
              Icons.directions_walk,
              tr('focus_break_stretch'),
              Colors.orange,
            ),
            _buildBreakOption(
              Icons.visibility_off,
              tr('focus_break_eyes'),
              Colors.green,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakOption(IconData icon, String label, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _remainingSeconds / (_selectedMinutes * 60);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            if (_isRunning) {
              _pauseTimer();
            }
            context.pop();
          },
        ),
        title: Text(
          tr('focus_adhd_timer'),
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.black87),
            onPressed: () {
              HelpDialog.show(
                context,
                titleKey: 'help_adhd_timer_title',
                purposeKey: 'help_adhd_timer_purpose',
                benefitsKey: 'help_adhd_timer_benefits',
                howToUseKey: 'help_adhd_timer_how_to_use',
                tipKeys: [
                  'help_adhd_timer_tip1',
                  'help_adhd_timer_tip2',
                  'help_adhd_timer_tip3',
                ],
                primaryColor: const Color(0xFF4CAF50),
              );
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
                const SizedBox(width: 4),
                Text(
                  '$_completedBlocks',
                  style: const TextStyle(
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildTimerDisplay(),
            const SizedBox(height: 60),
            if (!_isRunning && !_isPaused) _buildPresetButtons(),
            if (!_isRunning && !_isPaused) _buildCustomSlider(),
            const Spacer(),
            _buildControlButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerDisplay() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 280 + (_isRunning ? _pulseController.value * 10 : 0),
                height: 280 + (_isRunning ? _pulseController.value * 10 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50).withOpacity(0.05),
                ),
              );
            },
          ),
          SizedBox(
            width: 260,
            height: 260,
            child: CustomPaint(
              painter: CircularProgressPainter(
                progress: 1 - (_remainingSeconds / (_selectedMinutes * 60)),
                color: const Color(0xFF4CAF50),
                backgroundColor: Colors.grey.shade300,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (_isRunning || _isPaused)
                      Text(
                        _isPaused ? tr('focus_timer_paused') : tr('focus_timer_focusing'),
                        style: TextStyle(
                          fontSize: 16,
                          color: _isPaused ? Colors.orange : const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _presetMinutes.map((minutes) {
          final isSelected = _selectedMinutes == minutes;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedMinutes = minutes;
                _remainingSeconds = minutes * 60;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF4CAF50) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isSelected 
                        ? const Color(0xFF4CAF50).withOpacity(0.3)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$minutes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        children: [
          Text(
            tr('focus_timer_custom'),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF4CAF50),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: const Color(0xFF4CAF50),
              overlayColor: const Color(0xFF4CAF50).withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
            ),
            child: Slider(
              value: _selectedMinutes.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              label: '$_selectedMinutes ${tr('focus_timer_minutes')}',
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedMinutes = value.round();
                  _remainingSeconds = _selectedMinutes * 60;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_isRunning || _isPaused)
            _buildControlButton(
              onTap: _resetTimer,
              icon: Icons.stop,
              color: Colors.red,
              size: 56,
            ),
          _buildControlButton(
            onTap: () {
              if (_isRunning) {
                _pauseTimer();
              } else if (_isPaused) {
                _resumeTimer();
              } else {
                _startTimer();
              }
            },
            icon: _isRunning 
                ? Icons.pause 
                : Icons.play_arrow,
            color: const Color(0xFF4CAF50),
            size: 80,
            isPrimary: true,
          ),
          if (_isRunning || _isPaused)
            _buildControlButton(
              onTap: () => context.push('/focus/task-breakdown'),
              icon: Icons.checklist,
              color: const Color(0xFF2196F3),
              size: 56,
            ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    required double size,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.8)],
                )
              : null,
          color: isPrimary ? null : color.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          size: size * 0.5,
          color: isPrimary ? Colors.white : color,
        ),
      ),
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}